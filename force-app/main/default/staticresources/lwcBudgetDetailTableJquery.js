window.myLib = (function () {
  return {
    setColorScheme: function () {
      console.log("IN JQUERY");
      let listTableRows = Array.from(document.getElementsByTagName("tr"));
      const shapesArrHCSpread = [...(listTableRows as any)];
      console.log(shapesArrHCSpread);
    }
  };
})();
