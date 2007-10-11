package Ocsinventory::Agent::AccountConfig;
use strict;
use warnings;

# AccountConfig read and write the setting for the client given by the server
# This file will be overwrite and is not designed to be changed by the user

# DESPITE ITS NAME, ACCOUNTCONFIG IS NOT A CONFIG FILE!

sub new {
  my (undef,$params) = @_;

  my $self = {};
  bless $self;

  $self->{params} = $params->{params};
  my $logger = $self->{logger} = $params->{logger};

  # Configuration reading
  $self->{xml} = {};

  if ($self->{params}->{conffile}) {
    if (! -f $self->{params}->{conffile}) {
        $logger->debug ('conffile file: `'. $self->{params}->{conffile}.
  	" doesn't exist. I create an empty one");
        $self->write();
    } else {
      $self->{xml} = XML::Simple::XMLin(
        $self->{params}->{conffile},
        SuppressEmpty => undef
      );
    }
  }
  
  $self;
}

sub get {
  my ($self, $name) = @_;

  my $logger = $self->{logger};

  return $self->{xml}->{$name} if $name;
  return $self->{xml};
}

sub set {
  my ($self, $name, $value) = @_;

  my $logger = $self->{logger};

  $self->{xml}->{$name} = $value;
  $self->write(); # save the change
}


sub write {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  
  return unless $self->{params}->{conffile};
  my $xml = XML::Simple::XMLout( $self->{xml} , RootName => 'CONF',
    NoAttr => 1 );

  my $fault;
  if (!open CONF, ">".$self->{params}->{conffile}) {

    $fault = 1;

  } else {

    print CONF $xml;
    $fault = 1 if (!close CONF);

  }

  if (!$fault) {
    $logger->debug ("ocsinv.conf updated successfully");
  } else {

    $logger->error ("Can't save setting change in `$self->{params}->{conffile}'");
  }
}

1;