package WebGUI::Form;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use HTTP::BrowserDetect;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form

=head1 DESCRIPTION

Base forms package. Eliminates some of the normal code work that goes along with creating forms. Used by the HTMLForm package.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::button({value=>"Click me!", extras=>qq|onclick="alert('Aaaaggggghhh!!!')"|});
 $html = WebGUI::Form::checkbox({name=>"whichOne", value=>"red"});
 $html = WebGUI::Form::checkList({name=>"dayOfWeek", options=>\%days});
 $html = WebGUI::Form::combo({name=>"fruit",options=>\%fruit});
 $html = WebGUI::Form::contentType({name=>"contentType");
 $html = WebGUI::Form::databaseLink();
 $html = WebGUI::Form::date({name=>"endDate", value=>$endDate});
 $html = WebGUI::Form::dateTime({name=>"begin", value=>$begin});
 $html = WebGUI::Form::email({name=>"emailAddress"});
 $html = WebGUI::Form::fieldType({name=>"fieldType");
 $html = WebGUI::Form::file({name=>"image"});
 $html = WebGUI::Form::formFooter();
 $html = WebGUI::Form::formHeader();
 $html = WebGUI::Form::filterContent({value=>"javascript"});
 $html = WebGUI::Form::float({name=>"distance"});
 $html = WebGUI::Form::group({name=>"groupToPost"});
 $html = WebGUI::Form::hidden({name=>"wid",value=>"55"});
 $html = WebGUI::Form::hiddenList({name=>"wid",value=>"55",options=>\%options});
 $html = WebGUI::Form::HTMLArea({name=>"description"});
 $html = WebGUI::Form::integer({name=>"size"});
 $html = WebGUI::Form::interval({name=>"timeToLive", interval=>12, units=>"hours"});
 $html = WebGUI::Form::password({name=>"identifier"});
 $html = WebGUI::Form::phone({name=>"cellPhone"});
 $html = WebGUI::Form::radio({name=>"whichOne", value=>"red"});
 $html = WebGUI::Form::radioList({name="dayOfWeek", options=>\%days});
 $html = WebGUI::Form::selectList({name=>"dayOfWeek", options=>\%days, value=>\@array"});
 $html = WebGUI::Form::submit();
 $html = WebGUI::Form::template({name=>"templateId"});
 $html = WebGUI::Form::text({name=>"firstName"});
 $html = WebGUI::Form::textarea({name=>"emailMessage"});
 $html = WebGUI::Form::timeField({name=>"begin", value=>$begin});
 $html = WebGUI::Form::url({name=>"homepage"});
 $html = WebGUI::Form::yesNo({name=>"happy"});
 $html = WebGUI::Form::zipcode({name=>"workZip"});

=head1 METHODS 

All of the functions in this package accept the input of a hash reference containing the parameters to populate the form element. These functions are available from this package:

=cut


#-------------------------------------------------------------------
sub _fixMacros {
	my $value = shift;
	$value =~ s/\^/\&\#94\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------
sub _fixSpecialCharacters {
	my $value = shift;
	$value =~ s/\&/\&amp\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixTags {
	my $value = shift;
	$value =~ s/\</\&lt\;/g;
        $value =~ s/\>/\&gt\;/g;
	return $value;
}


#-------------------------------------------------------------------

=head2 button ( hashRef )

Returns a button. Use it in combination with scripting code to make the button perform an action.

=head3 value

The button text for this submit button. Defaults to "save".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onClick="alert(\'You've just pushed me !\')"'

=cut

sub button {
        my ($label, $extras, $subtext, $class, $output, $name, $value);
        $value = $_[0]->{value} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
        return '<input type="button" value="'.$value.'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 checkbox ( hashRef )

Returns a checkbox form element.

=head3 name

The name field for this form element.

=head3 checked 

If you'd like this box to be defaultly checked, set this to "1".

=head3 value

The default value for this form element. Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub checkbox {
        my ($checkedText, $value);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        $value = $_[0]->{value} || 1;
        return '<input type="checkbox" name="'.$_[0]->{name}.'" value="'.$value.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 checkList ( hashRef )

Returns checkbox list.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub checkList {
        my ($output, $checked, $key, $item);
        foreach $key (keys %{$_[0]->{options}}) {
		$checked = 0;
		foreach $item (@{$_[0]->{value}}) {
                        if ($item eq $key) {
                                $checked = 1;
                        }
                }
		$output .= checkbox({
			name=>$_[0]->{name},
			value=>$key,
			extras=>$_[0]->{extras},
			checked=>$checked
			});
                $output .= ${$_[0]->{options}}{$key};
		if ($_[0]->{vertical}) {
			$output .= "<br />\n";
		} else {
			$output .= " &nbsp; &nbsp;\n";
		}
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 combo ( hashRef )

Returns a select list and a text field. If the text box is filled out it will have a value stored in "name"_new.

=head3 name

The name field for this form element.

=head3 options

The list of options for the select list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub combo {
        my ($output, $size);
	$_[0]->{options}->{''} = '['.WebGUI::International::get(582).']';
	$_[0]->{options}->{_new_} = WebGUI::International::get(581).'-&gt;';
	$output = selectList({
		name=>$_[0]->{name},
		options=>$_[0]->{options},
		value=>$_[0]->{value},
		multiple=>$_[0]->{multiple},
		extras=>$_[0]->{extras}
		});
	$size =  $session{setting}{textBoxSize}-5;
        $output .= text({name=>$_[0]->{name}."_new",size=>$size});
	return $output;
}

#-------------------------------------------------------------------

=head2 contentType ( hashRef )

Returns a content type select list field. This is usually used to help tell WebGUI how to treat posted content.

=head3 name

The name field for this form element.

=head3 types 

An array reference of field types to be displayed. The types are "mixed", "html", "code", and "text".  Defaults to all.

=head3 value

The default value for this form element. Defaults to "mixed".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub contentType {
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) It was done this way because a huge
	# if/elsif construct executes much more quickly than a bunch of
	# unnecessary database hits.
	my @types = qw(mixed html code text);
	$_[0]->{types} = \@types unless ($_[0]->{types});
	foreach $type (@{$_[0]->{types}}) {
		if ($type eq "text") {
			$hash{text} = WebGUI::International::get(1010);
		} elsif ($type eq "mixed") {
			$hash{mixed} = WebGUI::International::get(1008);
		} elsif ($type eq "code") {
			$hash{code} = WebGUI::International::get(1011);
		} elsif ($type eq "html") {
        		$hash{html} = WebGUI::International::get(1009);
		}
	}
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras}
		});
}


#-------------------------------------------------------------------
                                                                                                                                                             
=head2 databaseLink ( hashRef )
                                                                                                                                                             
Returns a select list of database links.
                                                                                                                                                             
=head3 name
                                                                                                                                                             
The name field for this form element. Defaults to "databaseLinkId".
                                                                                                                                                             
=head3 value
                                                                                                                                                             
The unique identifier for the selected template. Defaults to "0", which is the WebGUI database.
                                                                                                                                                             
=cut
                                                                                                                                                             
sub databaseLink {
        my $value = $_[0]->{value} || 0;
        my $name = $_[0]->{name} || "databaseLinkId";
        return selectList({
                name=>$name,
                options=>WebGUI::DatabaseLink::getList(),
                value=>[$value]
                });
}
                                                                                                                                                             





#-------------------------------------------------------------------

=head2 date ( hashRef )

Returns a date field.

=head3 name

The name field for this form element.

=head3 value

The default date. Pass as an epoch value. Defaults to today.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 noDate

By default a date is placed in the "value" field. Set this to "1" to turn off the default date.

=cut

sub date {
	my $value = epochToSet($_[0]->{value}) unless ($_[0]->{noDate} && $_[0]->{value} eq '');
        my $size = $_[0]->{size} || 10;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar.js',{ language=>'javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/lang/calendar-en.js',{ language=>'javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar-setup.js',{ language=>'javascript' });
	WebGUI::Style::setLink($session{config}{extrasURL}.'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
	return text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'id="'.$_[0]->{name}.'Id" '.$_[0]->{extras},
		maxlength=>10
		}) . '<script type="text/javascript"> 
			Calendar.setup({ 
				inputField : "'.$_[0]->{name}.'Id", 
				ifFormat : "%Y-%m-%d", 
				showsTime : false, 
				timeFormat : "12",
				mondayFirst : false
				}); 
			</script>';
}



#-------------------------------------------------------------------

=head2 dateTime ( hashRef )

Returns a date/time field.

=head3 name

The the base name for this form element. This form element actually returns two values under different names. They are name_date and name_time.

=head3 value

The date and time. Pass as an epoch value. Defaults to today and now.

=head3 extras 

Extra parameters to add to the date/time form element such as javascript or stylesheet information.

=cut

sub dateTime {
	my $value = epochToSet($_[0]->{value},1);
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar.js',{ language=>'javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/lang/calendar-en.js',{ language=>'javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar-setup.js',{ language=>'javascript' });
	WebGUI::Style::setLink($session{config}{extrasURL}.'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
        return text({
                name=>$_[0]->{name},
                value=>$value,
                size=>19,
                extras=>'id="'.$_[0]->{name}.'Id" '.$_[0]->{extras},
                maxlength=>19
                }) . '<script type="text/javascript">
                        Calendar.setup({
                                inputField : "'.$_[0]->{name}.'Id",
                                ifFormat : "%Y-%m-%d %H:%M:%S",
                                showsTime : true,
                                timeFormat : "12",
                                mondayFirst : false
                                });
                        </script>';
}

#-------------------------------------------------------------------

=head2 dynamicField ( fieldType , hashRef )
                                                                                                                         
Returns a dynamic configurable field.
                                                                                                                         
=head3 fieldType

The field type to use. The field name is the name of the method from this forms package.

=head3 options

The field options. See the documentation for the desired field for more information.
                                                                                                                         
=cut

sub dynamicField {
	my $fieldType = shift;
	my $param = shift;

        # Set options for fields that use a list.
        if (isIn($fieldType,qw(selectList checkList radioList))) {
                delete $param->{size};
                my %options;
                tie %options, 'Tie::IxHash';
                foreach (split(/\n/, $param->{possibleValues})) {
                        s/\s+$//; # remove trailing spaces
                        $options{$_} = $_;
                }
		if (exists $param->{options} && ref($param->{options}) eq "HASH") {
			%options = (%{$param->{options}} , %options);
		}
                $param->{options} = \%options;
        }
        # Convert value to list for selectList / checkList
        if (isIn($fieldType,qw(selectList checkList)) && ref $param->{value} ne "ARRAY") {
                my @defaultValues;
                foreach (split(/\n/, $param->{value})) {
                                s/\s+$//; # remove trailing spaces
                                push(@defaultValues, $_);
                }
                $param->{value} = \@defaultValues;
        }

	# Return the appropriate field.
	no strict 'refs';
	return &$fieldType($param);

}

#-------------------------------------------------------------------

=head2 email ( hashRef )

Returns an email address field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub email {
	WebGUI::Style::setScript($session{config}{extrasURL}.'/emailCheck.js',{ language=>'javascript' });
	my $output .= text({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		size=>$_[0]->{size},
		extras=>' onChange="emailCheck(this.value)" '.$_[0]->{extras}
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 fieldType ( hashRef )

Returns a field type select list field. This is primarily useful for building dynamic form builders.

=head3 name

The name field for this form element.

=head3 types 

An array reference of field types to be displayed. The field names are the names of the methods from this forms package. Note that not all field types are supported. Defaults to all.

=head3 value

The default value for this form element.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub fieldType {
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) 
	my @types = qw(dateTime time float zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList);
	$_[0]->{types} = \@types unless ($_[0]->{types});
	foreach $type (@{$_[0]->{types}}) {
		if ($type eq "text") {
			$hash{text} = WebGUI::International::get(475);
		} elsif ($type eq "timeField") {
        		$hash{timeField} = WebGUI::International::get(971);
		} elsif ($type eq "dateTime") {
        		$hash{dateTime} = WebGUI::International::get(972);
		} elsif ($type eq "textarea") {
        		$hash{textarea} = WebGUI::International::get(476);
		} elsif ($type eq "HTMLArea") {
        		$hash{HTMLArea} = WebGUI::International::get(477);
		} elsif ($type eq "url") {
        		$hash{url} = WebGUI::International::get(478);
		} elsif ($type eq "date") {
        		$hash{date} = WebGUI::International::get(479);
		} elsif ($type eq "float") {
        		$hash{float} = WebGUI::International::get("float");
		} elsif ($type eq "email") {
        		$hash{email} = WebGUI::International::get(480);
		} elsif ($type eq "phone") {
        		$hash{phone} = WebGUI::International::get(481);
		} elsif ($type eq "integer") {
        		$hash{integer} = WebGUI::International::get(482);
		} elsif ($type eq "yesNo") {
        		$hash{yesNo} = WebGUI::International::get(483);
		} elsif ($type eq "selectList") {
        		$hash{selectList} = WebGUI::International::get(484);
		} elsif ($type eq "radioList") {
        		$hash{radioList} = WebGUI::International::get(942);
		} elsif ($type eq "checkList") {
        		$hash{checkList} = WebGUI::International::get(941);
		} elsif ($type eq "zipcode") {
			$hash{zipcode} = WebGUI::International::get(944);
		} elsif ($type eq "checkbox") {
        		$hash{checkbox} = WebGUI::International::get(943);
		}
	}
	# This is a hack for reverse compatibility with a bug where this field used to allow an array ref.
	my $value = $_[0]->{value};
	unless ($value eq "ARRAY") {
		$value = [$value];
	}
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras},
		size=>$_[0]->{size}
		});
}

#-------------------------------------------------------------------

=head2 file ( hashRef )

Returns a file upload field.

=head3 name

The name field for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub file {
        my ($size);
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="file" name="'.$_[0]->{name}.'" size="'.$size.'" '.$_[0]->{extras}.'>';
}


#-------------------------------------------------------------------

=head2 filterContent ( hashRef )

Returns a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

=head3 name

The name field for this form element. This defaults to "filterContent".

=head3 value

The default value for this form element. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub filterContent {
	my %filter;
	tie %filter, 'Tie::IxHash';
	%filter = (
		'none'=>WebGUI::International::get(420), 
                'macros'=>WebGUI::International::get(891), 
                'javascript'=>WebGUI::International::get(526), 
		'most'=>WebGUI::International::get(421),
		'all'=>WebGUI::International::get(419)
		);
	my $name = $_[0]->{name} || "filterContent";
        return selectList({
		name=>$name,
		options=>\%filter,
		value=>[$_[0]->{value}],
		extras=>$_[0]->{extras}
		});
}

#-------------------------------------------------------------------

=head2 formFooter ( )

Returns a form footer.

=cut

sub formFooter {
	return "</div></form>\n\n";
}


#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Returns a form header.

=head3 action

The form action. Defaults to the current page.

=head3 method

The form method. Defaults to "POST".

=head3 enctype

The form enctype. Defaults to "multipart/form-data".

=head3 extras

If you want to add anything special to the form header like javascript actions or stylesheet info, then use this.

=cut

sub formHeader {
        my $action = $_[0]->{action} || WebGUI::URL::page();
	my $hidden;
	if ($action =~ /\?/) {
		my ($path,$query) = split(/\?/,$action);
		$action = $path;
		my @params = split(/\&/,$query);
		foreach my $param (@params) {
			$param =~ s/amp;(.*)/$1/;
			my ($name,$value) = split(/\=/,$param);
			$hidden .= hidden({name=>$name,value=>$value});
		}
	}
        my $method = $_[0]->{method} || "POST";
        my $enctype = $_[0]->{enctype} || "multipart/form-data";
	return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$_[0]->{extras}.'><div class="formContents">'.$hidden;
}


#-------------------------------------------------------------------

=head2 float ( hashRef )

Returns an floating point field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub float {
        my $value = $_[0]->{value} || 0;
        my $size = $_[0]->{size} || 11;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ language=>'javascript' });
	return text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789.\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength}
		});
}




#-------------------------------------------------------------------

=head2 group ( hashRef ] )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=head3 name

The name field for this form element.

=head3 value 

The selected group id(s) for this form element.  This should be passed as an array reference. Defaults to "7" (Everyone).

=head3 size

How many rows should be displayed at once?

=head3 multiple

Set to "1" if multiple groups should be selectable.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 excludeGroups

An array reference containing a list of groups to exclude from the list.

=cut

sub group {
        my (%hash, $value, $where);
	$value = $_[0]->{value};
	if ($$value[0] eq "") { #doing long form otherwise arrayRef didn't work
		$value = [7];
	}
	tie %hash, 'Tie::IxHash';
	my $exclude = $_[0]->{excludeGroups};
	if ($$exclude[0] ne "") {
		$where = "and groupId not in (".quoteAndJoin($exclude).")";
	}
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where showInForms=1 $where order by groupName");
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$value,
		extras=>$_[0]->{extras},
		size=>$_[0]->{size},
		multiple=>$_[0]->{multiple}
		});
		
}

#-------------------------------------------------------------------

=head2 hidden ( hashRef )

Returns a hidden field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=cut

sub hidden {
        return '<input type="hidden" name="'.$_[0]->{name}.'" value="'._fixQuotes(_fixMacros(_fixSpecialCharacters($_[0]->{value}))).'" />'."\n";
}


#-------------------------------------------------------------------

=head2 hiddenList ( hashRef )

Returns a list of hidden fields. This is primarily to be used by the HTMLForm package, but we decided to make it a public method in case anybody else had a use for it.

=head3 name

The name of this field.

=head3 options 

A hash reference where the key is the "name" of the hidden field.

=head3 value

An array reference where each value in the array should be a name from the hash (if you want it to show up in the hidden list). 

=cut

sub hiddenList {
        my ($output, $key, $item);
        foreach $key (keys %{$_[0]->{options}}) {
                foreach $item (@{$_[0]->{value}}) {
                        if ($item eq $key) {
				$output .= hidden({
					name=>$_[0]->{name},
					value=>$key
					});
                        }
                }
        }
        return $output."\n";
}



#-------------------------------------------------------------------

=head2 HTMLArea ( hashRef )

Returns an HTML area. An HTML area is different than a standard text area in that it provides rich edit functionality and some special error trapping for HTML and other special characters.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 popupToggle

Defaults to "0". If set to "1" the rich editor will be a pop-up editor. If set to "0" the rich editor will be inline.

B<NOTE:> WebGUI uses a great variety of rich editors. Not all of them are capable of inline mode, so even if you leave this set to "0" the editor may be a pop-up anyway.

=cut

sub HTMLArea {
        my ($output, $rows, $columns, $htmlArea);
	my $browser = HTTP::BrowserDetect->new($session{env}{HTTP_USER_AGENT});
	my %var;

	# Store all scalar options in template variables
        foreach (keys %{$_[0]}) {
           $var{"form.".$_} = $_[0]->{$_} unless (ref $_[0]->{$_});
        }

	# Supported Rich Editors
	$var{"htmlArea.supported"} = ($browser->ie && $browser->version >= 5.5);
	$var{"midas.supported"} = (($browser->ie && $browser->version >= 6) || ($browser->gecko && $browser->version >= 1.3));
	$var{"htmlArea3.supported"} = (($browser->ie && $browser->version >= 5.5) || $var{"midas.supported"});
	$var{"classic.supported"} = ($browser->ie && $browser->version >= 5);
 
	# Textarea field
        $rows = $_[0]->{rows} || ($session{setting}{textAreaRows}+15);
        $columns = $_[0]->{columns} || ($session{setting}{textAreaCols}+5);
        $var{textarea} = textarea({
                name=>$_[0]->{name},
                value=>$_[0]->{value},
                wrap=>$_[0]->{wrap},
                columns=>$columns,
                rows=>$rows,
                extras=>$_[0]->{extras}.' onBlur="fixChars(this.form.'.$_[0]->{name}.')" id="'.$_[0]->{name}.'"'
                });

	# Other variables
	$var{"popup"} = ($session{user}{richEditorMode} eq "popup" || $_[0]->{popupToggle});
	$var{"button"} = '<input type="button" onClick="openEditWindow(this.form.'.$_[0]->{name}.')" value="'
                .WebGUI::International::get(171).'" style="font-size: 8pt;"><br>';
	if ($session{user}{richEditor} eq 'none') {
		return $var{textarea};
	} else {
		return WebGUI::Template::process($session{user}{richEditor},'richEditor',\%var);
	}
}

#-------------------------------------------------------------------

=head2 integer ( hashRef )

Returns an integer field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub integer {
        my $value = $_[0]->{value} || 0;
        my $size = $_[0]->{size} || 11;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ language=>'javascript' });
	return text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789-\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength}
		});
}

#-------------------------------------------------------------------

=head2 interval ( hashRef )

Returns a time interval field.

=head3 name

The the base name for this form element. This form element actually returns two values under different names. They are name_interval and name_units.

=head3 intervalValue

The default value for interval portion of this form element. Defaults to '1'.

=head3 unitsValue

The default value for units portion of this form element. Defaults to 'seconds'. Possible values are 'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', and 'years'.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub interval {
        my (%units, $output, $intervalValue, $unitsValue);
        $intervalValue = (defined $_[0]->{intervalValue}) ? $_[0]->{intervalValue} : 1;
        $unitsValue = $_[0]->{unitsValue} || "seconds";
        tie %units, 'Tie::IxHash';
	%units = ('seconds'=>WebGUI::International::get(704),
		'minutes'=>WebGUI::International::get(705),
		'hours'=>WebGUI::International::get(706),
		'days'=>WebGUI::International::get(700),
                'weeks'=>WebGUI::International::get(701),
                'months'=>WebGUI::International::get(702),
                'years'=>WebGUI::International::get(703));
	$output = integer({
		name=>$_[0]->{name}.'_interval',
		value=>$intervalValue,
		extras=>$_[0]->{extras}
		});
	$output .= selectList({
		name=>$_[0]->{name}.'_units',
		value=>[$unitsValue],
		options=>\%units
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 password ( hashRef )

Returns a password field. 

=head3 name 

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength 

The maximum number of characters to allow in this form element. Defaults to "35".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size 

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to "30" unless overridden in the settings.

=cut

sub password {
        my ($size, $maxLength, $value);
	$value = _fixQuotes($_[0]->{value});
        $maxLength = $_[0]->{maxlength} || 35;
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="password" name="'.$_[0]->{name}.'" value="'.$value.'" size="'.
		$size.'" maxlength="'.$maxLength.'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 phone ( hashRef )

Returns a telephone number field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub phone {
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ language=>'javascript' });
        my $maxLength = $_[0]->{maxlength} || 30;
	return text({
		name=>$_[0]->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789-()+ \')" '.$_[0]->{extras},
		value=>$_[0]->{value},
		size=>$_[0]->{size}
		});
}

#-------------------------------------------------------------------

=head2 radio ( hashRef )

Returns a radio button.

=head3 name

The name field for this form element.

=head3 checked

If you'd like this radio button to be defaultly checked, set this to "1".

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'


=cut

sub radio {
        my ($checkedText);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        return '<input type="radio" name="'.$_[0]->{name}.'" value="'.$_[0]->{value}.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 radioList ( hashRef )

Returns a radio button list field.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 value

The default value for this form element. This should be passed as a scalar.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub radioList {
        my ($output, $key, $checked);
        foreach $key (keys %{$_[0]->{options}}) {
		$checked = 0;
                $checked = 1 if ($key eq $_[0]->{value});
		$output .= radio({
			name=>$_[0]->{name},
			value=>$key,
			checked=>$checked,
			extras=>$_[0]->{extras}
			});
		$output .= ' '.$_[0]->{options}->{$key};
                if ($_[0]->{vertical}) {
                        $output .= "<br />\n";
                } else {
                        $output .= " &nbsp; &nbsp;\n";
                }
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 selectList ( hashRef )

Returns a select list field.

=head3 name

The name field for this form element.

=head3 options 

The list of options for this select list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size 

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 sortByValue

A boolean value for whether or not the values in the options hash should be sorted.

=cut

sub selectList {
	my ($output, $key, $item, $size, $multiple);
	$size = $_[0]->{size} || 1;
	$multiple = ' multiple="1"' if ($_[0]->{multiple});
       	$output = '<select name="'.$_[0]->{name}.'" size="'.$size.'" '.$_[0]->{extras}.$multiple.'>';
	my %options;
        tie %options, 'Tie::IxHash';
       	if ($_[0]->{sortByValue}) {
               	foreach my $optionKey (sort {"\L${$_[0]->{options}}{$a}" cmp "\L${$_[0]->{options}}{$b}" } keys %{$_[0]->{options}}) {
                         $options{$optionKey} = ${$_[0]->{options}}{$optionKey};
               	}
       	} else {
               	%options = %{$_[0]->{options}};
       	}
       	foreach $key (keys %options) {
           	$output .= '<option value="'.$key.'"';
          	 foreach $item (@{$_[0]->{value}}) {
             		if ($item eq $key) {
             			$output .= ' selected="1"';
             		}
           	}
           	$output .= '>'.${$_[0]->{options}}{$key}.'</option>';
	}
	$output	.= '</select>'; 
	return $output;
}


#-------------------------------------------------------------------

=head2 submit ( hashRef )

Returns a submit button.

=head3 value

The button text for this submit button. Defaults to "save".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub submit {
        my ($label, $extras, $subtext, $class, $output, $name, $value, $wait);
        $value = $_[0]->{value} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
	$wait = WebGUI::International::get(452);
	return '<input type="submit" value="'.$value.'" onClick="this.value=\''.$wait.'\'" '.$_[0]->{extras}.'>';

}

#-------------------------------------------------------------------

=head2 template ( hashRef )

Returns a select list of templates.

=head3 name

The name field for this form element. Defaults to "templateId".

=head3 value 

The unique identifier for the selected template. Defaults to "1".

=head3 namespace

The namespace for the list of templates to return. If this is omitted, all templates will be displayed.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub template {
        my $templateId = $_[0]->{value} || 1;
	my $name = $_[0]->{name} || "templateId";
        return selectList({
                name=>$name,
                options=>WebGUI::Template::getList($_[0]->{namespace}),
                value=>[$templateId],
		extras=>$_[0]->{extras}
                });
}

#-------------------------------------------------------------------

=head2 text ( hashRef )

Returns a text input field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub text {
        my ($size, $maxLength, $value);
        $value = _fixSpecialCharacters($_[0]->{value});
	$value = _fixQuotes($value);
	$value = _fixMacros($value);
        $maxLength = $_[0]->{maxlength} || 255;
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="text" name="'.$_[0]->{name}.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$_[0]->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 textarea ( hashRef )

Returns a text area field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows 

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub textarea {
        my ($columns, $value, $rows, $wrap);
	$wrap = $_[0]->{wrap} || "virtual";
	$rows = $_[0]->{rows} || $session{setting}{textAreaRows} || 5;
	$columns = $_[0]->{columns} || $session{setting}{textAreaCols} || 50;
	$value = _fixSpecialCharacters($_[0]->{value});
	$value = _fixTags($value);
	$value = _fixMacros($value);
        return '<textarea name="'.$_[0]->{name}.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.
		$wrap.'" '.$_[0]->{extras}.'>'.$value.'</textarea>';
}

#-------------------------------------------------------------------

=head2 timeField ( hashRef )

Returns a time field, 24 hour format.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element. Defaults to the current time (like "15:03:42").

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 8.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to 8.

=cut

sub timeField {
        my $value = WebGUI::DateTime::secondsToTime($_[0]->{value});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ language=>'javascript' });
	my $output = text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$_[0]->{size} || 8,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789:\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength} || 8
		});
	$output .= '<input type="button" style="font-size: 8pt;" onClick="window.timeField = this.form.'.
		$_[0]->{name}.';clockSet = window.open(\''.$session{config}{extrasURL}.
		'/timeChooser.html\',\'timeChooser\',\'WIDTH=230,HEIGHT=100\');return false" value="'.
		WebGUI::International::get(970).'">';
	return $output;
}

#-------------------------------------------------------------------

=head2 url ( hashRef )

Returns a URL field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 2048.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub url {
        my $maxLength = $_[0]->{maxlength} || 2048;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/addHTTP.js',{ language=>'javascript' });
	return text({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras}.' onBlur="addHTTP(this.form.'.$_[0]->{name}.')"',
		size=>$_[0]->{size},
		maxlength=>$maxLength
		});
}

#-------------------------------------------------------------------

=head2 whatNext ( hashRef ] )

Returns a "What next?" select list for use with chained action forms in WebGUI.

=head3 options

A hash reference of the possible actions that could happen next.

=head3 value

The selected element in this list. 

=head3 name

The name field for this form element. Defaults to "proceed".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub whatNext {
        my ($name);
        $name = $_[0]->{name} || "proceed";
        return selectList({
                options=>$_[0]->{options},
                name=>$name,
                value=>[$_[0]->{value}],
                extras=>$_[0]->{extras}
                });

}

#-------------------------------------------------------------------

=head2 yesNo ( hashRef )

Returns a yes/no radio field. 

=head3 name

The name field for this form element.

=head3 value

The default value(s) for this form element. Valid values are "1" and "0". Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut

sub yesNo {
        my ($subtext, $checkYes, $checkNo, $class, $output, $name, $label, $extras, $value);
	if ($_[0]->{value}) {
		$checkYes = 1;
	} else {
		$checkNo = 1;
	}
	$output = radio({
		checked=>$checkYes,
		name=>$_[0]->{name},
		value=>1,
		extras=>$_[0]->{extras}
		});
	$output .= WebGUI::International::get(138);
	$output .= '&nbsp;&nbsp;&nbsp;';
	$output .= radio({
                checked=>$checkNo,
                name=>$_[0]->{name},
                value=>0,
                extras=>$_[0]->{extras}
                });
        $output .= WebGUI::International::get(139);
	return $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( hashRef )

Returns a zip code field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub zipcode {
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ language=>'javascript' });
        my $maxLength = $_[0]->{maxlength} || 10;
	return text({
		name=>$_[0]->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- \')" '.$_[0]->{extras},
		value=>$_[0]->{value},
		size=>$_[0]->{size}
		});
}




1;


