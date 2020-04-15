require HTTP::Request;
require LWP::UserAgent;

%sitesHit = ();
$sitesHit{"https://xkcd.com/387/"} = 1;
$targetfile = "target.txt";
$emailfile = "emails.txt";
$readfile = "read.txt";

$validLine = 1;
while($validLine == 1) {
	open(TARGET, "<", $targetfile);
	$line = <TARGET>;
	chomp $line;
	while(exists($sitesHit{$line})) {
		$line = <TARGET>;
		chomp $line;
		print $line;
	}
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
			push @newSites, "\n$1";
		}
		elsif ($r =~ /href="([\w\/\.\:\$]*?)"/) {
			print "tag for anchor: $1 \n";
			push @newSites, "\n$root$1";
		}
		elsif ($r =~ /mailto\:(.*?)"/) {
			print "mail to: $1";
			push @emails, "\n$1";
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
	print READ $line;
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