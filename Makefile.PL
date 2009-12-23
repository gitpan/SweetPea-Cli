use inc::Module::Install;
  
# Define metadata
name           'SweetPea-Cli';
all_from       'lib/SweetPea/Cli.pm';

# Specific dependencies
requires       'Cwd'                    => '0';
requires       'Exception::Handler'     => '0';
requires       'Hash::Merge::Simple'    => '0';
requires       'Test/Differences'       => '0';
requires       'File::ShareDir'         => '0';
requires       'File::Util'             => '0';
requires       'Template'               => '0';
requires       'IO'                     => '0';
requires       'HTTP::Server::Simple'   => '0';
requires       'SweetPea'               => '2.364';
requires       'SweetPea::Application'  => '0.022';

#requires       'SweetPea::Server'       => '0';

include        'App::Rad'               => '1.05';

test_requires  'Test::More'             => '0.42';

no_index       package                  => 'App::Rad';
no_index       package                  => 'Module::Install';

install_script 'script/sweetpea';
install_share  'script/files';

license        'perl';
perl_version   '5.006';

WriteAll;