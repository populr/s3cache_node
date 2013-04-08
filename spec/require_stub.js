var originalRequire = require;
var requireOverrides = {};

stubModule = function(name) {
  var double = originalRequire(name);
  double['double'] = name;
  requireOverrides[name] = double;
  return double;
}

require = function(name) {
  if (requireOverrides[name]) {
    return requireOverrides[name];
  } else {
    return originalRequire(name);
  }
}

afterEach(function() {
  requireOverrides = {};
});