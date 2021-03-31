# This file has been generated by node2nix 1.9.0. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {};
in
{
  "jquery-3.5.1" = nodeEnv.buildNodePackage {
    name = "jquery";
    packageName = "jquery";
    version = "3.5.1";
    src = fetchurl {
      url = "https://registry.npmjs.org/jquery/-/jquery-3.5.1.tgz";
      sha512 = "XwIBPqcMn57FxfT+Go5pzySnm4KWkT1Tv7gjrpT1srtf8Weynl6R273VJ5GjkRb51IzMp5nbaPjJXMWeju2MKg==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "JavaScript library for DOM operations";
      homepage = "https://jquery.com";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  "bootstrap-4.5.1" = nodeEnv.buildNodePackage {
    name = "bootstrap";
    packageName = "bootstrap";
    version = "4.5.1";
    src = fetchurl {
      url = "https://registry.npmjs.org/bootstrap/-/bootstrap-4.5.1.tgz";
      sha512 = "bxUooHBSbvefnIZfjD0LE8nfdPKrtiFy2sgrxQwUZ0UpFzpjVbVMUxaGIoo9XWT4B2LG1HX6UQg0UMOakT0prQ==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "The most popular front-end framework for developing responsive, mobile first projects on the web.";
      homepage = "https://getbootstrap.com/";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  "viz.js-2.1.2" = nodeEnv.buildNodePackage {
    name = "viz.js";
    packageName = "viz.js";
    version = "2.1.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/viz.js/-/viz.js-2.1.2.tgz";
      sha512 = "UO6CPAuEMJ8oNR0gLLNl+wUiIzQUsyUOp8SyyDKTqVRBtq7kk1VnFmIZW8QufjxGrGEuI+LVR7p/C7uEKy0LQw==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "A hack to put Graphviz on the web.";
      homepage = "https://github.com/mdaines/viz.js";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
