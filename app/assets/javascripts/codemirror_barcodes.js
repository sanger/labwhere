"use strict";

CodeMirror.defineMode("barcode_reader", function (cm) {
  function tokenBase(stream, state) {
    var ch = stream.next();
    if (/\w/.test(ch)) {
      stream.eatWhile(/[\w\.]/);
      var readBarcode = stream.current();
      if (state.barcodes.indexOf(readBarcode) >= 0) {
        return "strong error";
      } else {
        state.barcodes.push(readBarcode)
        return "tag";
      }
    }
  }

  // Interface

  return {
    startState: function () {
      return { barcodes: [] };
    },

    token: function (stream, state) {
      if (stream.eatSpace()) return null;
      var style = tokenBase(stream, state);
      return style;
    }
  };
});