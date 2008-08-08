# AssHAT - A plugin for Movable Type.
# Copyright (c) 2007, Arvind Satyanarayan.
# This program is distributed under the terms of the
# GNU General Public License, version 2.

package MT::Plugin::AssHAT;

use 5.006;    # requires Perl 5.6.x
use MT 4.0;   # requires MT 4.0 or later

use base 'MT::Plugin';
our $VERSION = '1.0';

my $plugin;
MT->add_plugin($plugin = __PACKAGE__->new({
	name            => 'AssHAT',
	version         => $VERSION,
	description     => '<__trans phrase="AssHAT allows you to mass manage assets in Movable Type">',
	author_name     => 'Arvind Satyanarayan',
	author_link     => 'http://www.movalog.com/',
	plugin_link     => 'http://plugins.movalog.com/asshat/',
	doc_link        => 'http://plugins.movalog.com/asshat/'
}));

# Allows external access to plugin object: MT::Plugin::AssHAT->instance
sub instance { $plugin; }

sub init_registry {
	my $plugin = shift;
	$plugin->registry({
		applications => {
			cms => {
				list_actions => {
					asset => {
						'asshat_batch_editor' => {
			                label     => 'Batch Edit Assets',
			                code      => sub { runner('open_batch_editor', 'AssHAT::App::CMS', @_); },
			                order     => 300,
			                condition => sub {
			                    MT->instance->param('blog_id');
			                },
			            },
					}
				},
				methods => {
					'asshat_batch_editor' => sub { runner('open_batch_editor', 'AssHAT::App::CMS', @_); },
					'save_assets' => sub { runner('save_assets', 'AssHAT::App::CMS', @_); },
					'start_asshat_transporter' => sub { runner('start_transporter', 'AssHAT::App::CMS', @_); },
					'asshat_transport_assets' => sub { runner('transport', 'AssHAT::App::CMS', @_); }
				}
			}
		},
		callbacks => {
			'MT::App::CMS::template_source.list_asset' => sub { runner('list_asset_src', 'AssHAT::App::CMS', @_); }
		}
	});
}

sub runner {
    my $method = shift;
	my $class = shift;
    eval "require $class;";
    if ($@) { die $@; $@ = undef; return 1; }
    my $method_ref = $class->can($method);
    return $method_ref->($plugin, @_) if $method_ref;
    die $plugin->translate("Failed to find [_1]::[_2]", $class, $method);
}

1;