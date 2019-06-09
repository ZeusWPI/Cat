var xhttp = new XMLHttpRequest();
xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        var responseData = this.responseText;
        console.log(responseData);
        loadGraph(JSON.parse(responseData));
    }
};
xhttp.open("GET", "relations_zeroed", true);
xhttp.send();


function loadGraph(request_data) {

    var nodes = new vis.DataSet(
        request_data["nodes"].map(node => {
            return {
                id: node.index,
                label: node.name.slice(0,30) + (node.name.length > 30 ? "..." : ""),
                color: 'hsl('+Math.floor(Math.random()*361)+',50%,75%)'
            };
        })
    );
    var edges = new vis.DataSet(
        request_data["links"].map(link => {
            return {
                from: link.source,
                to: link.target
            };
        })
    );

    var container = document.getElementById("view");
    var data = {
        nodes: nodes,
        edges: edges
    };
    var options = {};
    var network = new vis.Network(container, data, options);
}
