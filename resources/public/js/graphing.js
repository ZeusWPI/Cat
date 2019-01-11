var view;

vega.loader()
    .load('/js/spec.json')
    .then(function(data) { render(JSON.parse(data)); });

function render(spec) {
    view = new vega.View(vega.parse(spec))
        .renderer('canvas')  // set renderer (canvas or svg)
        .initialize('#view') // initialize view within parent DOM container
        .hover()             // enable hover encode set processing
        .run();
}