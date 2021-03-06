# ==========================================================================
#
# ZoneMinder Wanscam HW0025 IP Control Protocol Module, $Date: 2009-11-25 09:20:00 +0000 (Wed, 04 Nov 2009) $, $Revision: 0001 $
# Copyright (C) 2001-2015 Florian Neumair
# Modified for use with Foscam FI8918W IP Camera by Dave Harris
# Modified Feb 2011 by Howard Durdle (http://durdl.es/x) to:
#      fix horizontal panning, add presets and IR on/off
#      use Control Device field to pass username and password
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# ==========================================================================
#
# This module contains the implementation of the Wanscam HW0025 IP camera control
# protocol
#
# Known working Devices:
# * Wanscam HW0025
# * IPCC-7210W
#
package ZoneMinder::Control::WanscamHW0025;
 
use 5.006;
use strict;
use warnings;

require ZoneMinder::Base;
require ZoneMinder::Control;

our @ISA = qw(ZoneMinder::Control);
 
# ==========================================================================
#
# Wanscam HW0025 IP Control Protocol
#
# ==========================================================================
 
use ZoneMinder::Logger qw(:all);
use ZoneMinder::Config qw(:all);

use Time::HiRes qw( usleep );
 
sub new
{ 
	my $class = shift;
	my $id = shift;
	my $self = ZoneMinder::Control->new( $id );
	bless( $self, $class );
	srand( time() );
	return $self;
}
 
our $AUTOLOAD;
 
sub AUTOLOAD
{
    my $self = shift;
    my $class = ref($self) || croak( "$self not object" );
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    if ( exists($self->{$name}) )
    {
        return( $self->{$name} );
    }
    Fatal( "Can't access $name member of object of class $class" );
}
 
sub open
{
    my $self = shift;

    $self->loadMonitor();

    use LWP::UserAgent;
    $self->{ua} = LWP::UserAgent->new;
    $self->{ua}->agent( "ZoneMinder Control Agent/".ZoneMinder::Base::ZM_VERSION );

    $self->{state} = 'open';
}
 
sub close
{ 
	my $self = shift;
	$self->{state} = 'closed';
}
 
sub printMsg
{
	my $self = shift;
	my $msg = shift;
	my $msg_len = length($msg);
 
	Debug( $msg."[".$msg_len."]" );
}

sub sendCmd
{
    my $self = shift;
    my $cmd = shift;

    my $result = undef;

    printMsg( $cmd, "Tx" );

    #print( "http://$address/$cmd\n" );
    my $req = HTTP::Request->new( GET=>"http://".$self->{Monitor}->{ControlAddress}."/$cmd".$self->{Monitor}->{ControlDevice} );
	Info( "http://".$self->{Monitor}->{ControlAddress}."/$cmd".$self->{Monitor}->{ControlDevice} );
    my $res = $self->{ua}->request($req);

    if ( $res->is_success )
    {
        $result = !undef;
    }
    else
    {
        Error( "Error check failed: '".$res->status_line()."'" );
    }

    return( $result );
}

 
sub cameraReset
{
	my $self = shift;
	Debug( "Camera Reset" );
	my $cmd = "reboot.cgi?";
	$self->sendCmd( $cmd );
}
 
#Up Arrow
sub moveConUp
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Up" );
	my $cmd = "decoder_control.cgi?command=0&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Down Arrow
sub moveConDown
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Down" );
	my $cmd = "decoder_control.cgi?command=2&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Left Arrow
sub moveConLeft
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Left" );
	my $cmd = "decoder_control.cgi?command=4&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Right Arrow
sub moveConRight
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Right" );
	my $cmd = "decoder_control.cgi?command=6&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Diagonally Up Right Arrow
sub moveConUpRight
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Diagonally Up Right" );
	my $cmd = "decoder_control.cgi?command=91&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Diagonally Down Right Arrow
sub moveConDownRight
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Diagonally Down Right" );
	my $cmd = "decoder_control.cgi?command=93&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Diagonally Up Left Arrow
sub moveConUpLeft
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Diagonally Up Left" );
	my $cmd = "decoder_control.cgi?command=90&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Diagonally Down Left Arrow
sub moveConDownLeft
{
	my $self = shift;
	my $params = shift;
	Debug( "Move Diagonally Down Left" );
	my $cmd = "decoder_control.cgi?command=92&onestep=1&";
	$self->sendCmd( $cmd );
	my $autostop = $self->getParam( $params, 'autostop', 0 );
    if ( $autostop && $self->{Monitor}->{AutoStopTimeout} )
    {
        usleep( $self->{Monitor}->{AutoStopTimeout} );
        $self->moveStop( $params );
    }
}
 
#Stop
sub moveStop
{
	my $self = shift;
	Debug( "Move Stop" );
	my $cmd = "decoder_control.cgi?command=1&onestep=1&";
	$self->sendCmd( $cmd );
}
 
#Move Camera to Home Position
sub presetHome
{
	my $self = shift;
	Debug( "Home Preset" );
	my $cmd = "decoder_control.cgi?command=25&onestep=0&";
	$self->sendCmd( $cmd );
}

# zoom out
sub zoomRelTele
{
    my $self = shift;
    Debug( "Zoom Tele" );
    my $cmd = "camera_control.cgi?param=17&value=1&";
    $self->sendCmd( $cmd );
}

#zoom in
sub zoomRelWide
{
    my $self = shift;
    Debug( "Zoom Wide" );
    my $cmd = "camera_control.cgi?param=18&value=1&";
    $self->sendCmd( $cmd );
}

 
#Set preset
sub presetSet
{
    my $self = shift;
    my $params = shift;
    my $preset = $self->getParam( $params, 'preset' );
	my $presetCmd = 30 + (($preset-1)*2);
    Debug( "Set Preset $preset with cmd $presetCmd" );
    my $cmd = "decoder_control.cgi?command=$presetCmd&onestep=0&sit=$presetCmd&";
    $self->sendCmd( $cmd );
}
 
#Goto preset
sub presetGoto
{
    my $self = shift;
    my $params = shift;
    my $preset = $self->getParam( $params, 'preset' );
    my $presetCmd = 31 + (($preset-1)*2);
    Debug( "Goto Preset $preset with cmd $presetCmd" );
    my $cmd = "decoder_control.cgi?command=$presetCmd&onestep=0&sit=$presetCmd&";
    $self->sendCmd( $cmd );
}
 
#Turn IR on
sub wake
{
	my $self = shift;
	Debug( "Wake - IR on" );
	my $cmd = "camera_control.cgi?param=14&value=1&";
	$self->sendCmd( $cmd );
}
 
#Turn IR off
sub sleep
{
	my $self = shift;
	Debug( "Sleep - IR off" );
	my $cmd = "camera_control.cgi?param=14&value=0&";
	$self->sendCmd( $cmd );
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

ZoneMinder::Database - Perl extension for blah blah blah

=head1 SYNOPSIS

  use ZoneMinder::Control::Wanscam
  blah blah blah

=head1 DESCRIPTION

Stub documentation for ZoneMinder, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.
=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Philip Coombes, <philip.coombes@zoneminder.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2001-2008  Philip Coombes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
