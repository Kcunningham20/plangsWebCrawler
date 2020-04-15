require HTTP::Request;
require LWP::UserAgent;

%sitesHit = ();
%emailShit = ();
$sitesHit{"https://xkcd.com/387/"} = 1;
#$emailShit{"jesus@God.com"} = 1;
$targetfile = "target.txt";
$emailfile = "emails.txt";
$readfile = "read.txt";

$validLine = 1;
while($validLine == 1) {
	open(TARGET, "<", $targetfile);
	$line = <TARGET>;
	chomp $line;
	@lines = <TARGET>;
	close(TARGET);

	print "\nCurrent Line Crawling: " .$line ."\n";
	$sitesHit{$line} = 1;

	open(TARGET, ">", $targetfile);
	print TARGET @lines;
	close(TARGET);

	$line =~ /(http[s]?\:\/\/.*)\/?/;
	$root = $1;
	print "Root is $root\n";
	@newSites;
	@emails;
	$req = HTTP::Request->new(GET=> $line);
	$ua = LWP::UserAgent->new;
	$response = $ua->request($req);
	#print $response->content;
	@resp = split(/\n/, $response->content);
	foreach $r (@resp) {
		chomp $r;
		
		if ($r =~ /(http[s]?\:\/\/.*?)"/) {
			print "absolute URL: $1 \n";
			print "Sites Hash: $sitesHit{$1}\n";
			if ($sitesHit{$1} != 1) {
				push @newSites, "\n$1";
				$sitesHit{$1} = 1;
			}
		}
		elsif ($r =~ /href="([\w\/\.\:\$]*?)"/) {
			print "tag for anchor: $1 \n";
			my $url = $root . $1;
			if ($sitesHit{$url} != 1) {
				push @newSites, "\n$url";
				$sitesHit{$url} = 1;
			}
		}
		elsif ($r =~ /mailto\:(.*?)"/) {
			print "mail to: $1\n";
			print "Email hash: $emailShit{$1}\n";
			if ($emailShit{$1} != 1) {
				push @emails, "\n$1";
				$emailShit{$1} = 1;
				print "Set Email Hash for $1: $emailShit{$1}\n";
			}
		}
		else {
			#print $r."\n";
		}
		#print "\n";
	}
	

	open(TARGET, ">>", $targetfile);
	print TARGET @newSites;
	close(TARGET);

	open(EMAILS, ">>", $emailfile);
	print EMAILS @emails;
	close(EMAILS);

	open(READ, ">>", $readfile);
	print READ "\n$line";
	close(READ);
	
	if (length(@lines)+length(@newSites) == 0) {
		$validLine = 0;
	}
}

#open(INFILE, "url.txt");
#add current site to this
#open(INFILE, "target.txt");
#add all urls we found on the current page
#close(INFILE);