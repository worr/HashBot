#
#===============================================================================
#
#    FILE:  HashBot.pm
#
#  DESCRIPTION:  HashBot Module
#
#   FILES:  ---
#    BUGS:  ---
#   NOTES:  ---
#  AUTHOR:  GRANT COHOE (cohoe@csh.rit.edu) 
# COMPANY:  
# VERSION:  1.0
# CREATED:  03/18/2012 04:13:21 PM
#REVISION:  ---
#  CREDIT:  Original project inspiration and code model by George Ornbo 
#           (Shape Shed) available at https://github.com/shapeshed/Arthur
#                
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, dis-
# tribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the fol-
# lowing conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIL-
# ITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#===============================================================================

package HashBot;

use strict;
use warnings;
use Net::Twitter;
use Scalar::Util 'blessed';

use Data::Dumper;

# Constructor
sub new {
	my ($class) = @_;
	my $self = {
		_searchString		=> undef,
		_consumerKey		=> undef,
		_consumerSecret		=> undef,
		_accessToken		=> undef,
		_accessTokenSecret	=> undef,
		_twitterUsername	=> undef,
		_twitterConnection	=> undef,
	};
	bless $self,$class;
	return $self;
}

# Accessor method for Search String
sub searchString {
    my ( $self, $searchString  ) = @_;
	$self->{_searchString } = $searchString if defined($searchString);
	return $self->{_searchString};
}

# Accessor method for the Consumer Key
sub consumerKey {
    my ( $self, $consumerKey ) = @_;
	$self->{_consumerKey} = $consumerKey if defined($consumerKey);
	return $self->{_consumerKey};
}

# Accessor method for the Consumer Secret
sub consumerSecret {
    my ( $self, $consumerSecret ) = @_;
	$self->{_consumerSecret} = $consumerSecret if defined($consumerSecret);
	return $self->{_consumerSecret};
}


# Accessor method for the Access Token
sub accessToken {
    my ( $self, $accessToken ) = @_;
	$self->{_accessToken} = $accessToken if defined($accessToken);
	return $self->{_accessToken};
}

# Accessor method for the Consumer Secret
sub accessTokenSecret {
    my ( $self, $accessTokenSecret ) = @_;
	$self->{_accessTokenSecret} = $accessTokenSecret if defined($accessTokenSecret);
	return $self->{_accessTokenSecret};
}

# Accessor method for the Twitter Username
sub twitterUsername {
    my ( $self, $twitterUsername ) = @_;
	$self->{_twitterUsername} = $twitterUsername if defined($twitterUsername);
	return $self->{_twitterUsername};
}

# Accessor method for the Twitter connection
sub twitterConnection {
	my ( $self ) = @_;
	$self->{_twitterConnection} = Net::Twitter->new(
		traits   => [qw/OAuth API::REST API::Search/],
		consumer_key		=> $self->consumerKey,
		consumer_secret		=> $self->consumerSecret,
		access_token		=> $self->accessToken,
		access_token_secret => $self->accessTokenSecret,
	);
	return $self->{_twitterConnection};
}

# Pull in data from Twitter
sub get_data {
	my ( $self ) = @_;
	my $results = $self->twitterConnection->search($self->searchString);
}

# Make the posts based on a certain set of criteria
sub post_to_twitter {
	my ( $self, $data ) = @_;
	
	foreach my $tweet (@{$data->{results}}) {
		#print $tweet->{from_user};
		
		# Don't retweet our tweets. That would be really bad.
		if($tweet->{from_user} ne $self->twitterUsername) {

			# Don't retweet retweets. It would be ugly.
			if ($tweet->{text} !~ /^(\s*)?(RT|rt)/) {

				# See if we have run before
				if(&get_status_id) {

					# Only RT things since the last runtime
					if ($tweet->{id} > &get_status_id) {
						post_tweet($tweet, $self);
					}
				}

				# First time run
				else {
					post_tweet($tweet, $self);
				}
			}
		}
	}

	# Write the latest ID to a file to track for next time
	&write_status_id($data->{results}[0]->{id});
}

# Send the data to Twitter
sub post_tweet {
	my ( $tweet, $self ) = @_;
	
	# This method just copies the text
	#my $result = $self->twitterConnection->update($tweet->{text});
	
	# This method actually retweets it
	my $result = $self->twitterConnection->retweet($tweet->{id});
}

# Load in the previous statusID from the file
sub get_status_id {
	if (-e "hashbot_last_status") {
		open(STATUS,"hashbot_last_status");
		my $last_status_id = <STATUS>;
		return($last_status_id);
	}
	else {
		return;
	}
}

# Write the new statusID to the file
sub write_status_id {
	my ( $status_id ) = @_;
	open (STATUS, ">hashbot_last_status");
	print STATUS $status_id;
	close(STATUS);
	return 1;
}
1;
