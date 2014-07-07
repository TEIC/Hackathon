$( function() {
	
	ODDVisualizer.TreeView = function() {
	    this.initialize.apply(this, arguments);
	};

	_.extend( ODDVisualizer.TreeView.prototype, {

		initialize: function() {

			var w = 1280 - 80,
			    h = 800 - 180;
			
			this.x = d3.scale.linear().range([0, w]);
			this.y = d3.scale.linear().range([0, h]);
			
			var    color = d3.scale.category20c(),
			    root,
			    node;

			var treemap = d3.layout.treemap()
			    .round(false)
			    .size([w, h])
			    .sticky(true)
			    .value(function(d) { return d.size; });

			this.svg = d3.select("#body").append("div")
			    .attr("class", "chart")
			    .style("width", w + "px")
			    .style("height", h + "px")
			  .append("svg:svg")
			    .attr("width", w)
			    .attr("height", h)
			  .append("svg:g")
			    .attr("transform", "translate(.5,.5)");

			d3.json("flare.json", _.bind( function(data) {
			  node = root = data;

			  var nodes = treemap.nodes(root)
			      .filter(function(d) { return !d.children; });

			  var cell = this.svg.selectAll("g")
			      .data(nodes)
			    .enter().append("svg:g")
			      .attr("class", "cell")
			      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
			      .on("click", _.bind( function(d) { return this.zoom(node == d.parent ? root : d.parent); }, this) );

			  cell.append("svg:rect")
			      .attr("width", function(d) { return d.dx - 1; })
			      .attr("height", function(d) { return d.dy - 1; })
			      .style("fill", function(d) { return color(d.parent.name); });

			  cell.append("svg:text")
			      .attr("x", function(d) { return d.dx / 2; })
			      .attr("y", function(d) { return d.dy / 2; })
			      .attr("dy", ".35em")
			      .attr("text-anchor", "middle")
			      .text(function(d) { return d.name; })
			      .style("opacity", function(d) { d.w = this.getComputedTextLength(); return d.dx > d.w ? 1 : 0; });

			  d3.select(window).on("click", _.bind( function() { this.zoom(root); }, this));

			  d3.select("select").on("change", _.bind( function() {
			    treemap.value(this.value == "size" ? this.size : this.count).nodes(root);
			    this.zoom(node);
			  }, this));
			}, this));
			
			this.w = w;
			this.h = h;
		},
		
		size: function(d) {
		  return d.size;
		},

		count: function(d) {
		  return 1;
		},

		zoom: function(d) {
		  var kx = this.w / d.dx, ky = this.h / d.dy;
		  this.x.domain([d.x, d.x + d.dx]);
		  this.y.domain([d.y, d.y + d.dy]);

		  var t = this.svg.selectAll("g.cell").transition()
		      .duration(d3.event.altKey ? 7500 : 750)
		      .attr("transform", _.bind( function(d) { return "translate(" + this.x(d.x) + "," + this.y(d.y) + ")"; }, this));

		  t.select("rect")
		      .attr("width", function(d) { return kx * d.dx - 1; })
		      .attr("height", function(d) { return ky * d.dy - 1; })

		  t.select("text")
		      .attr("x", function(d) { return kx * d.dx / 2; })
		      .attr("y", function(d) { return ky * d.dy / 2; })
		      .style("opacity", function(d) { return kx * d.dx > d.w ? 1 : 0; });

		  node = d;
		  d3.event.stopPropagation();
		}
	
	});

});