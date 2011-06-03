package Test::WebGUI::Asset::Wobject::SQLReport;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset::Wobject/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub assetUiLevel {
     return 5;
}

sub list_of_tables {
     return [qw/assetData wobject SQLReport/];
}

sub postProcessMergedProperties {
    my ( $test, $props ) = @_;
    $props->{dbQuery1} = "SELECT * FROM users";
}

1;
