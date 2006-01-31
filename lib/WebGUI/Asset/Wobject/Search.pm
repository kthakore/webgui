package WebGUI::Asset::Wobject::Search;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base "WebGUI::Asset::Wobject";
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Paginator;

=head1 NAME

Package WebGUI::Asset::Wobject::Search

=head1 DESCRIPTION

Asset used to search WebGUI content.

=head2 definition ( $class, $definition )

This method defines all properties of a Search and is used to autogenerate most methods.

=head3 $class

$class is used to make sure that inheritance works on Assets and Wobjects.

=head3 $definition

Definition hashref from subclasses.

=head3 Search specific properties

=over 4

=item templateId

ID of a tempate from the Search namespace to display the search results.

=back

=cut

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Search');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000200',	
				tab=>"display",
				namespace=>"Search",
                		hoverHelp=>$i18n->get('search template description'),
                		label=>$i18n->get('search template')
				},
			searchRoot => {
				fieldType=>"asset",
				defaultValue=>$session->setting->get("defaultPage"),
				tab=>"properties",
				hoverHelp=>$i18n->get("search root description"),
				label=>$i18n->get('search root')
				},
			classLimiter => {
				fieldType => "checkList",
				defaultValue => undef,
				vertical=>1,
				tab=>"properties",
				hoverHelp=>$i18n->get("class limiter description"),
				label=>$i18n->get("class limiter"),
				options=>$session->db->buildHashRef("select distinct(className) from asset")
				}
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'search.gif',
		autoGenerateForms=>1,
		tableName=>'search',
		className=>'WebGUI::Asset::Wobject::Search',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_Search");
	my %var;
	$var{'form_header'} = WebGUI::Form::formHeader($self->session, {action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session,{name=>"doit", value=>"1"});
	$var{'form_footer'} = WebGUI::Form::formFooter($self->session);
	$var{'form_submit'} = WebGUI::Form::submit($self->session, {value=>$i18n->get("search")});
	$var{'form_keywords'} = WebGUI::Form::text($self->session, {name=>"keywords", value=>$self->session->form->get("keywords")});
	if ($self->session->form->get("doit")) {
		my $search = WebGUI::Search->new($self->session);
		my %rules = (
			keywords=>$self->session->form->get("keywords"), 
#			lineage=>[$self->getValue("searchRoot")]
			);
		my @classes = split("\n",$self->get("classLimiter"));
#		$rules{classes} = \@classes if (scalar(@classes));
		$search->search(\%rules);
		my @results = ();
		my $rs = $search->getResultSet;
		while (my $data = $rs->hashRef) {
			next unless ($self->session->user->userId eq $data->{ownerUserId} || $self->session->user->isInGroup($data->{groupIdView}) || $self->session->user->isInGroup($data->{groupIdEdit}));
			push(@results, {
				url=>$data->{url},
				title=>$data->{title},
				synposis=>$data->{synopsis},
				});
		} 
		my $p = WebGUI::Paginator->new($self->session,$self->getUrl);
		$p->setDataByArrayRef(\@results);	
		$p->appendTemplateVars(\%var);
		$var{result_set} = $p->getPageData;
	}
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

1;

