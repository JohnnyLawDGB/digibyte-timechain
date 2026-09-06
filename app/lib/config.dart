/// Base URL of the DigiScope backend API. Override: --dart-define=CHAIN_API_BASE=http://10.0.2.2:3001/api
const String kApiBase = String.fromEnvironment('CHAIN_API_BASE', defaultValue: 'https://api.digiscope.me/api');
const String kExplorerBase = 'https://digiscope.me/explorer/block/';
