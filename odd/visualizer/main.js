var D3Test = {};

$( function() {
	
	D3Test.Main = function() {
	    this.initialize.apply(this, arguments);
	};

	_.extend( D3Test.Main.prototype, {

		initialize: function() {
			
			_.bindAll( this, "color", "click", "tick");
			
			var width = 960;
			var height = 500;

			this.force = d3.layout.force()
			    .size([width, height])
			    .on("tick", this.tick);

			var svg = d3.select("body").append("svg")
			    .attr("width", width)
			    .attr("height", height);

			this.link = svg.selectAll(".link");
			this.node = svg.selectAll(".node");

			d3.json("readme.json", _.bind( function(json) {
			  this.root = json;
			  this.update();
			}, this));
		},
		
		update: function() {
		  var nodes = this.flatten(this.root),
		      links = d3.layout.tree().links(nodes);

		  // Restart the force layout.
		  this.force
		      .nodes(nodes)
		      .links(links)
		      .start();

		  // Update the links…
		  this.link = this.link.data(links, function(d) { return d.target.id; });

		  // Exit any old links.
		  this.link.exit().remove();

		  // Enter any new links.
		  this.link.enter().insert("line", ".node")
		      .attr("class", "link")
		      .attr("x1", function(d) { return d.source.x; })
		      .attr("y1", function(d) { return d.source.y; })
		      .attr("x2", function(d) { return d.target.x; })
		      .attr("y2", function(d) { return d.target.y; });

		  // Update the nodes…
		  this.node = this.node.data(nodes, function(d) { return d.id; }).style("fill", this.color);

		  // Exit any old nodes.
		  this.node.exit().remove();

		  // Enter any new nodes.
		  this.node.enter().append("circle")
		      .attr("class", "node")
		      .attr("cx", function(d) { return d.x; })
		      .attr("cy", function(d) { return d.y; })
		      .attr("r", function(d) { return Math.sqrt(d.size) / 10 || 4.5; })
		      .style("fill", this.color)
		      .on("click", this.click )
		      .call(this.force.drag);
		},
		
		tick: function() {
		  this.link.attr("x1", function(d) { return d.source.x; })
		      .attr("y1", function(d) { return d.source.y; })
		      .attr("x2", function(d) { return d.target.x; })
		      .attr("y2", function(d) { return d.target.y; });

		  this.node.attr("cx", function(d) { return d.x; })
		      .attr("cy", function(d) { return d.y; });
		},

		// Color leaf nodes orange, and packages white or blue.
		color: function(d) {
		  return d._children ? "#3182bd" : d.children ? "#c6dbef" : "#fd8d3c";
		},

		// Toggle children on click.
		click: function(d) {
		  if (!d3.event.defaultPrevented) {
		    if (d.children) {
		      d._children = d.children;
		      d.children = null;
		    } else {
		      d.children = d._children;
		      d._children = null;
		    }
		    this.update();
		  }
		},

		// Returns a list of all nodes under the root.
		flatten: function(root) {
		  var nodes = [], i = 0;

		  function recurse(node) {
		    if (node.children) node.children.forEach(recurse);
		    if (!node.id) node.id = ++i;
		    nodes.push(node);
		  }

		  recurse(root);
		  return nodes;
		}

	});

});