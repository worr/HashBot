HashBot: A Twitter ReTweeting Robot

OVERVIEW:
This robot operates by searching for tweets about a certain topic and
retweeting them. A common use of this is to retweet all tweets containing 
a certain hashtag. It stores a local file that contains a timestamp 
identifier to prevent you from constantly retweeting the same things.

DEPENDENCIES:
Perl 5
Net::Twitter

INSTALLATION:
Configure the options in bot.pl based on the example provided. The 
information you need is in the Twitter Developer area. Note that 
you need to register an application with your Twitter account first.
This Application needs Read-Write access to your account.

USAGE:
Just run `perl bot.pl`. Alternatively you can schedule the job to 
run every X interval with Cron.

SOURCE:
Available on Github (cohoe/HashBot).
