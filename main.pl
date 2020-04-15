require HTTP::Request;
require LWP::UserAgent;

open(INFILE, "target.txt");
#@lines = <INFILE>;
#print @lines;
$line = <INFILE>; #read in first line
close(INFILE);

print "\nCurrent Line Crawling: " .$line ."\n";

$req = HTTP::Request->new(GET=> $line);
$ua = LWP::UserAgent->new;
$response = $ua->request($req);
#print $response->content;
@resp = split(/\n/, $response->content);
foreach $r (@resp) {
	chomp $r;
	if ($r =~ /(href="[\w\/\.\:\$]*?)"/) {
		print "tag for anchor: $1 \n";
	}
	elsif ($r =~ /http\:\/\//) {
		#print "absolute URLS: $r";
	}
	elsif ($r =~ /mailto\:(.*)/) {
		#print "email addresses: $r";
	}
	elsif ($r =~ /(http:\/\/[\w*\.]*\w*)\/.*/) {
		#print "server addresses in URL: $r";
	}
	else {
		#print $r."\n";
	}
	#print "\n";
}

#open(INFILE, "url.txt");
#add current site to this
#open(INFILE, "target.txt");
#add all urls we found on the current page
#close(INFILE);