package WebGUI;
our $VERSION = "6.2.7";
our $STATUS = "gamma";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use WebGUI::Affiliate;
use WebGUI::Cache;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTTP;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::PassiveProfiling;


#-------------------------------------------------------------------	
sub _generatePage {
	my $content = shift;
	if ($session{form}{op} eq "" && $session{setting}{trackPageStatistics} && $session{form}{wid} ne "new") {
		WebGUI::SQL->write("insert into pageStatistics (dateStamp, userId, username, ipAddress, userAgent, referer,
			pageId, pageTitle, wobjectId, wobjectFunction) values (".time().",".quote($session{user}{userId})
			.",".quote($session{user}{username}).",
			".quote($session{env}{REMOTE_ADDR}).", ".quote($session{env}{HTTP_USER_AGENT}).",
			".quote($session{env}{HTTP_REFERER}).", ".quote($session{page}{pageId}).", 
			".quote($session{page}{title}).", ".quote($session{form}{wid}).", ".quote($session{form}{func}).")");
	}
	my $output = WebGUI::Style::process($content);
        if ($session{setting}{showDebug} || ($session{form}{debug}==1 && WebGUI::Grouping::isInGroup(3))) {
		$output .= WebGUI::ErrorHandler::showDebug();
        }
	return $output;
}

#-------------------------------------------------------------------
sub _getPageInfo {
	my $sql = "select * from page where "; 
	my $url = shift || $ENV{PATH_INFO};
	$url = lc($url);
	$url =~ s/\/$//;
        $url =~ s/^\///;
        $url =~ s/\'//;
        $url =~ s/\"//;
	my $pageData;
        if ($url ne "") {
		$pageData = WebGUI::SQL->quickHashRef($sql."urlizedTitle=".quote($url));
                if ($pageData->{subroutine} eq "") {
                        if($ENV{"MOD_PERL"}) {
                                my $r = Apache->request;
                                if(defined($r)) {
                                        $r->custom_response(404, $url);
                                        $r->status(404);
                                }
                        } else {
                                $session{http}{status} = '404';
                        }
			$pageData = WebGUI::SQL->quickHashRef($sql."pageId=".quote($session{setting}{notFoundPage}));
                }
        } else {
		$pageData = WebGUI::SQL->quickHashRef($sql."pageId=".quote($session{setting}{defaultPage}));
        }
	$session{page} = $pageData;
	return $pageData;
}

#-------------------------------------------------------------------	
sub _processOperations {
	my ($cmd, $output);
	my $op = $session{form}{op};
	my $opNumber = shift || 1;
        if ($op) {
		$output = WebGUI::Operation::execute($op);
        }
	$opNumber++;
	if ($output eq "" && exists $session{form}{"op".$opNumber}) {
		my $urlString = WebGUI::URL::unescape($session{form}{"op".$opNumber});
		my @pairs = split(/\&/,$urlString);
		my %form;
		foreach my $pair (@pairs) {
			my @param = split(/\=/,$pair);
			$form{$param[0]} = $param[1];
		}
		$session{form} = \%form;
		$output = _processOperations($opNumber);
	}
	return $output;
}

#-------------------------------------------------------------------
sub page {
	my $webguiRoot = shift;
	my $configFile = shift;
	my $useExistingSession = shift;   # used for static page generation functions where  you may generate more than one page at a time.
	my $pageUrl = shift;
	my $fastcgi = shift;
	WebGUI::Session::open($webguiRoot,$configFile,$fastcgi) unless ($useExistingSession);
	my $page = _getPageInfo($pageUrl);
	my $output = _processOperations();
	if ($output ne "") {
		$output = _generatePage($output);
	} else {
        	my $useCache = (
			$session{form}{op} eq "" && 
			$session{form}{func} eq "" && 
			(
				( $session{page}{cacheTimeout} > 10 && $session{user}{userId} !=1) || 
				( $session{page}{cacheTimeoutVisitor} > 10 && $session{user}{userId} == 1)
			) && 
			not $session{var}{adminOn}
		);
		my $cache;
		if ($useCache) {
                	$cache = WebGUI::Cache->new("page_".$session{page}{pageId}."_".$session{user}{userId});
               		$output = $cache->get;
		}
		unless ($output) {
			my $cmd = "use ".$page->{subroutinePackage};
			eval ($cmd);
			WebGUI::ErrorHandler::fatalError("Couldn't compile page package: ".$page->{subroutinePackage}.". Root cause: ".$@) if ($@);
			my $params = eval $page->{subroutineParams};
			WebGUI::ErrorHandler::fatalError("Couldn't interpret page params: ".$page->{subroutineParams}.". Root cause: ".$@) if ($@);
			$cmd = $page->{subroutinePackage}."::".$page->{subroutine};
			$output = eval{&$cmd($params)};
			WebGUI::ErrorHandler::fatalError("Couldn't execute page command: ".$page->{subroutine}.". Root cause: ".$@) if ($@);
			if (WebGUI::HTTP::getMimeType() eq "text/html") {
				$output = _generatePage($output);
			}
			my $ttl;
			if ($session{user}{userId} == 1) {
				$ttl = $session{page}{cacheTimeoutVisitor};
			} else {
				$ttl = $session{page}{cacheTimeout};
			}
			$cache->set($output, $ttl) if ($useCache && !WebGUI::HTTP::isRedirect());
			WebGUI::PassiveProfiling::addPage();	# add wobjects on page to passive profile log
		}
	}
	WebGUI::Affiliate::grabReferral();	# process affilliate tracking request
	if (WebGUI::HTTP::isRedirect() && !$useExistingSession) {
                $output = WebGUI::HTTP::getHeader();
        } else {
                $output = WebGUI::HTTP::getHeader().$output;
        }
	# This allows an operation or wobject to write directly to the browser.
	$output = undef if ($session{page}{empty});
	WebGUI::Session::close() unless ($useExistingSession);
	return $output;
}




1;


