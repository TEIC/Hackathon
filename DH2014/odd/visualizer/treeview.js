$(function() {

	ODDVisualizer.TreeView = function() {
		this.initialize.apply(this, arguments);
	};

	_.extend(ODDVisualizer.TreeView.prototype, {
		
		icons: {
			attributes: "\u0040",
			desc: "\u2026"		
		},
		
		initialize: function() {

			var w = 1280 - 80,
				h = 800 - 180;

			this.x = d3.scale.linear().range([0, w]);
			this.y = d3.scale.linear().range([0, h]);

			this.treemap = d3.layout.treemap().round(false).size([w, h]).sticky(true).value(function(d) {
				return d.size;
			});

			this.svg = d3.select("#body").append("div").attr("class", "chart").style("width", w + "px").style("height", h + "px").append("svg:svg").attr("width", w).attr("height", h).append("svg:g").attr("transform", "translate(.5,.5)");

			this.w = w;
			this.h = h;

			d3.json("../data/p5subset.json", _.bind(this.parseData, this));

		},

		parseData: function(p5data) {

			var oddTree = {
			    "modules" : {}
			  };

			 var p5elements = {};

		    _.map(p5data.members, function(m) {
		      if (m.type == "elementSpec"){
		        p5elements[m.ident] = m;

		        if (oddTree.modules[m.module] == undefined) {
		          oddTree.modules[m.module] = {
		            "name" : m.module,
		            "included" : false,
		            "elements" : {}
		          }
		        }
		        else {
		          oddTree.modules[m.module].elements[m.ident] = {
		            "name" : m.ident,
		            "mode" : "unknown",
		            "changes" : {},
		            "score" : 1,
					"included": false
		          }
		        }

		      }

		    });

		    // Then load customization
		    d3.json("../data/james.json", _.bind( function(data) {
		    
		      var elements = _.filter(data.members, function(m) {
		        return m.type == "elementSpec";
		      });

		      _.each(elements, function(el){

		        oddTree.modules[el.module].included = true;

		        var struct = {
		          "name" : el.ident,
		          "mode" : "unknown",
		          "changes" : {},
		          "score" : 1,
				  "included": true
		        }

		        // different desc
		        if (p5elements[el.ident].desc != el.desc){
		          struct.score++;
		          struct.changes["desc"] = true;
		        }

		        // attribute number
		        var p5attlength = p5elements[el.ident].attributes.length;
		        var attrlength = el.attributes.length;
		        if (p5attlength != attrlength){
		          struct.score += attrlength - p5attlength;
		          struct.changes["attributes"] = true;
		        }

		        // new attribute values
		        _.map(el.attributes, function(attr){
		          var p5attr = _.filter(p5elements[el.ident].attributes, function(a){
		            return a.ident == attr.ident
		          });
		          if (p5attr.values == undefined || p5attr.values == null) {
		            p5attr.values = [];
		          }
		          _.map(attr.values, function(v){
		            if (_.indexOf(p5attr.values, v) == -1){
		              struct.score++;
		              struct.changes["attributes"] = true;
		            }
		          });
		        });


		        oddTree.modules[el.module].elements[struct.name] = struct;

		      });

			  this.visualizeData(oddTree);

		    }, this));

		},

		visualizeData: function(data) {

			var treeData = {};
			treeData.children = _.map(data.modules, function(module, key) {
				var child = { name: key };
				child.children = _.map( module.elements, function( element, key ) {
					return { name: key, size: element.score, changes: element.changes, attributes: element.changes.attributes, desc: element.changes.desc, included: element.included };			
				});
				return child;
			});
			
			var node, root;
			node = root = treeData;

			var nodes = this.treemap.nodes(root).filter(function(d) {
				return !d.children;
			});

			var cell = this.svg.selectAll("g").data(nodes).enter().append("svg:g").attr("class", "cell").attr("transform", function(d) {
				return "translate(" + d.x + "," + d.y + ")";
			}).on("click", _.bind(function(d) {
				return this.zoom(node == d.parent ? root : d.parent);
			}, this));

			cell.append("svg:rect").attr("width", function(d) {
				return d.dx - 1;
			}).attr("height", function(d) {
				return d.dy - 1;
			}).style("fill", _.bind(this.selectColor, this));

			cell.append("svg:text").attr("x", function(d) {
				return d.dx / 2;
			}).attr("y", function(d) {
				return d.dy / 2;
			}).attr("dy", ".35em").attr("text-anchor", "middle").text( _.bind( this.selectIcon, this)).style("opacity", function(d) {
				d.w = this.getComputedTextLength();
				return d.dx > d.w ? 1 : 0;
			});

			// respond to click event
			d3.select(window).on("click", _.bind(function() {
				this.zoom(root);
			}, this));

			d3.select("select").on("change", _.bind(function() {
				this.treemap.value(this.value == "size" ? this.size : this.count).nodes(root);
				this.zoom(node);
			}, this));
			},
			
			selectColor: function(d) {
				if( d.attributes ) return "#FFAE19";
				if( d.desc ) return "#2665B2";
				if( d.included ) return "LightGray"; 
				return "White";
			},
			
			selectIcon: function(d) {	
				var displayString = d.name;
				if( d.attributes ) {
					displayString = this.icons.attributes + " " + displayString;
				}
				if( d.desc ) {
					displayString = this.icons.desc + " " + displayString;
				}
				return displayString;				
			},

			size: function(d) {
				return d.size;
			},

			count: function(d) {
				return 1;
			},

			zoom: function(d) {
				var kx = this.w / d.dx,
					ky = this.h / d.dy;
				this.x.domain([d.x, d.x + d.dx]);
				this.y.domain([d.y, d.y + d.dy]);

				var t = this.svg.selectAll("g.cell").transition().duration(d3.event.altKey ? 7500 : 750).attr("transform", _.bind(function(d) {
					return "translate(" + this.x(d.x) + "," + this.y(d.y) + ")";
				}, this));

				t.select("rect").attr("width", function(d) {
					return kx * d.dx - 1;
				}).attr("height", function(d) {
					return ky * d.dy - 1;
				})

				t.select("text").attr("x", function(d) {
					return kx * d.dx / 2;
				}).attr("y", function(d) {
					return ky * d.dy / 2;
				}).style("opacity", function(d) {
					return kx * d.dx > d.w ? 1 : 0;
				});

				node = d;
				d3.event.stopPropagation();
			}

		});

	});
