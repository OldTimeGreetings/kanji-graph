//$(document).ready(function(){


    var graph;
    function myGraph(vis_div) {

    this.readNodes = function() {
      return nodes;
    }

    // Add and remove elements on the graph object
    this.addNode = function (id, name) {
        nodes.push({"id":id, "name": name});
        update();
    };

    this.removeNode = function (id) {
        var i = 0;
        var n = findNode(id);
        while (i < links.length) {
            //individual links are objects
            if ((links[i]['source'] == n)||(links[i]['target'] == n))
            {
                //remove link
                links.splice(i,1);
            }
            else i++;
        }
        //remove node
        nodes.splice(findNodeIndex(id),1);
        update();
    };

    this.removeLink = function (source,target){
        for(var i=0;i<links.length;i++)
        {
            if(links[i].source.id == source && links[i].target.id == target)
            {
                links.splice(i,1);
                break;
            }
        }
        //redraw
        update();
    };

    this.removeallLinks = function(){
        links.splice(0,links.length);
        update();
    };

    this.removeAllNodes = function(){
        nodes.splice(0,links.length);
        update();
    };

    this.addLink = function (source_id, target_id, value) {
        //links are objects
        links.push({"source":findNode(source_id),"target":findNode(target_id),"value":value});
        update();
    };


    var findNode = function(id) {
      for (var i in nodes) {
        if (nodes[i]["id"] === id) return nodes[i];
      };
    };

    var findNodeIndex = function(id) {
        for (var i=0;i<nodes.length;i++) {
            if (nodes[i].id==id){
                return i;
            }
        };
    };

    // set up the D3 visualisation in the specified element
    var w = 500,
        h = 500;
    var vis = d3.select(vis_div)
        .append("svg:svg")
        .attr("width", w)
        .attr("height", h)
        .attr("id","svg")
        .attr("pointer-events", "all")
        .attr("viewBox","0 0 "+w+" "+h)
        .attr("perserveAspectRatio","xMinYMid")
        .append('svg:g');

    var force = d3.layout.force();
    force.charge(-120);

    var nodes = force.nodes(),
        links = force.links();

    var update = function () {
          var link = vis.selectAll("line")
            .data(links, function(d) {
                return d.source.id + "-" + d.target.id; 
            });

        link.enter().insert("line", ".node")
            .attr("id",function(d){return d.source.id + "-" + d.target.id;})
            .attr("class","link");
        link.append("title")
        .text(function(d){
            return d.value;
        });
        link.exit().remove();

        var node = vis.selectAll("g.node")
            .data(nodes);

        // handle nodes that don't exist yet
        var nodeEnter = node.enter().append("g")
            .attr("class", "node")
            .call(force.drag);

        var background = nodeEnter.append("circle")
              .attr("r", 12)
              .style("fill", "white");
        var text = nodeEnter.append("text")
              .attr("y", "5")
              .style("color", "#4b4b4b")
              .style('text-anchor', 'middle')
              .text(function(d) { 
                return d.name; });
        var circle = nodeEnter.append("circle")
              .attr("id", function(d) {return d.index})
              .attr("r", 12)
              .style("fill", "rgba(255, 255, 255, 0)")
              .style("stroke", "#4b4b4b");

        // nodeEnter.append("svg:circle")
        // .attr("r", 16)
        // .attr("id",function(d) { return "Node;"+d.id;})
        // .attr("class","nodeStrokeClass");

        // nodeEnter.append("svg:text")
        // .attr("class","textClass")
        // .text( function(d){return d.name;}) ;

        node.exit().remove();

        force.on("tick", function() {

              //   link.attr("d", function(d) {
              //   return "M" + d.source.x + "," + d.source.y
              //       + "S" + d.target.x + "," + d.target.y
              //       + " " + d.target.x + ", " + d.target.y;
                   
              // });

            node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y         + ")"; });

            link.attr("x1", function(d) { return d.source.x; })
              .attr("y1", function(d) { return d.source.y; })
              .attr("x2", function(d) { return d.target.x; })
              .attr("y2", function(d) { return d.target.y; });


        });

        // Restart the force layout.
        force
        .gravity(.05)
        .distance(50)
        .linkDistance( 50 )
        .size([w, h])
        .start();
    };


    // Make it all go
    update();
    }

    function drawGraph()
    {
      graph = new myGraph("#svgdiv");


      d3.json("surnames/directed_graph_small", function(error, json) {
        if (error) return console.warn(error);

        json.nodes.forEach(function(node){
          graph.addNode(node.id, node.name);
        });

        json.links.forEach(function(link){
          graph.addLink(link.source, link.target, '20');
        });


      });
    }
    drawGraph();
//});
