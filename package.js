Package.describe({
  name: 'youiest:unionize',
  version: '0.0.4',
  // Brief, one-line summary of the package.
  summary: ' for reactive network triggers with a simple ui',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/youiest/youiest-unionize.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});


// add grounddb here
Package.on_use(function (api) {
  api.versionsFrom('1.0.3.1');
  api.use(['matb33:collection-hooks@0.7.11','coffeescript'], ['client', 'server']);

  // like Document W will be an extended coll..
  api.export('Unionize');
  
  api.add_files([
    'lib.js'
  ], ['client','server']);

  api.add_files([
    'client.coffee'
  ], 'client');

  api.add_files([
    'server.coffee', 'publish.coffee'
  ], 'server');
});

Package.on_test(function (api) {
  api.versionsFrom('1.0.3.1');
  api.use(['underscore','ground:db@0.3.6','aldeed:console-me','matb33:collection-hooks@0.7.11','tracker', 'tinytest', 'test-helpers', 'coffeescript', 'insecure', 'accounts-base', 'accounts-password', 'underscore', 'random', 'pedrohenriquerls:reactjs'], ['client', 'server']);
  api.add_files([
    'lib.js',
    'testUpdateClient.coffee',
    'tests.coffee',
  ], ['client', 'server']);

  api.add_files([ 
    'server.js',
    'publish.coffee'
  ], ['server']);

  api.add_files([
    'client.coffee'
  ], ['client']);
  
  api.add_files([
    'react_test.coffee'
  ], ['client']);
});




