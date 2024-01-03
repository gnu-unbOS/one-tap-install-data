package ExtRepoData::Suite;

use strict;
use warnings;

use overload '<=>' => 'suitecmp', 'cmp' => 'suitecmp', '""' => 'output';

use Carp;
use Debian::DistroInfo;

my $info = DebianDistroInfo->new();

my %suites = (
	buzz => "1.1",
	rex => "1.2",
	bo => "1.3",
	hamm => "2.0",
	slink => "2.1",
	potato => "2.2",
	woody => "3.0",
	sarge => "3.1",
	etch => "4.0",
	lenny => "5.0",
	squeeze => "6.0",
	wheezy => "7.0",
	jessie => "8",
	stretch => "9",
	buster => "10",
	bullseye => "11",
	bookworm => "12",
	trixie => "13",
	sid => "9999",
	experimental => "10000",
);

my %symbolic = (
	oldstable => $info->old,
	stable => $info->stable,
	testing => $info->testing,
	unstable => $info->devel,
);

sub new {
	my $class = shift;
	my $val = shift;

	if(exists($symbolic{$val})) {
		$val = $symbolic{$val};
	}

	croak "Unknown Debian release: $val" unless exists($suites{$val});
	return bless \$val, $class;
}

sub suitecmp {
	my $self = shift;
	my $other = shift;
	my $swapped = shift;

	if(exists($symbolic{$other})) {
		$other = $symbolic{$other};
	}

	croak "Unknown Debian release: $other" unless exists($suites{$other});

	if($swapped) {
		return $suites{$other} <=> $suites{$$self};
	} else {
		return $suites{$$self} <=> $suites{$other};
	}
}

sub output {
	my $self = shift;

	return $$self;
}

sub version_of($) {
	my $suite = shift;
	if(exists($symbolic{$suite})) {
		$suite = $symbolic{$suite};
	}
	return $suites{$suite};
}

package ExtRepoData;

use strict;
use warnings;

sub TIEHASH {
	my $class = shift;
	my $self = {};
	$self->{data} = shift;
	$self->{index} = {};

	if(exists($self->{data}{"<<"})) {
		foreach my $key(keys %{$self->{data}{"<<"}}) {
			if(exists($self->{data}{$key})) {
				next unless ref($self->{data}{$key}) eq "HASH";
				foreach my $subkey(keys %{$self->{data}{"<<"}{$key}}) {
					next if exists($self->{data}{$key}{$subkey});
					$self->{data}{$key}{$subkey} = $self->{data}{"<<"}{$key}{$subkey};
				}
			} else {
				$self->{data}{$key} = $self->{data}{"<<"}{$key};
			}
		}
		delete $self->{data}{"<<"};
	}
	foreach my $key(keys %{$self->{data}}) {
		$self->{index}{lc($key)} = $key;
		if (ref($self->{data}{$key}) eq "HASH") {
			$self->{tied}{$key} = tie my(%hash), 'ExtRepoData', $self->{data}{$key};
			$self->{data}{$key} = \%hash;
		}
	}

	bless $self, $class;
}

sub FETCH {
	my ($self, $key) = @_;

	if(exists($self->{suite})) {
		my $suitekey = "suite-" . $self->{suite} . "-" . lc($key);
		if(exists($self->{index}{$suitekey})) {
			return $self->{data}{$self->{index}{$suitekey}};
		}
	}
	return $self->{data}{$self->{index}{lc($key)}};
}

sub STORE {
	my ($self, $key, $value) = @_;

	if(ref($value) eq "HASH") {
		$self->{tied}{$key} = tie my (%hash), 'ExtRepoData', $value;
		$self->{tied}{$key}->suite($self->{suite});
		$value = \%hash;
	}
	$self->{data}{$key} = $value;
	$self->{index}{lc($key)} = $key;
}

sub DELETE {
	my ($self, $key) = @_;

	delete $self->{data}{$key};
	delete $self->{index}{lc($key)};
}

sub CLEAR {
	my $self = shift;

	delete $self->{data};
	delete $self->{index};
	delete $self->{tied};
}

sub EXISTS {
	my ($self, $key) = @_;

	return exists $self->{index}{lc($key)};
}

sub FIRSTKEY {
	my $self = shift;
	my $a = keys %{$self->{data}};
	return $self->NEXTKEY;
}

sub NEXTKEY {
	my $self = shift;
	my $rv;
	do {
		$rv = each %{$self->{data}};
		return undef unless defined($rv);
		return $rv unless exists($self->{suite});
		if($rv =~ /^suite-([^-]+)-(.*)$/) {
			if($1 eq $self->{suite}) {
				return $2;
			}
		} else {
			my $keyname = "suite-" . $self->{suite} . "-" . lc($rv);
			if(!exists($self->{index}{$keyname})) {
				return $rv;
			}
		}
	} while(defined($rv));
	return undef;
}

sub SCALAR {
	my $self = shift;
	return scalar %{$self->{data}};
}

sub suite {
	my $self = shift;
	$self->{suite} = shift;
	foreach my $key(keys %{$self->{data}}) {
		if (ref($self->{data}{$key}) eq "HASH") {
			$self->{tied}{$key}->suite($self->{suite});
		}
	}
	delete $self->{suite} unless defined $self->{suite};
}

1;
