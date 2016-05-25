//craeting title for the data viz
d3.select("body")
	  .append("h3")
	  .text("Consumer's Financial Complaints in Each State");


//draw function
function draw(geo_data){
	var state;
	
	var projection = d3.geo.albersUsa()
					   .scale(600)
					   .translate([width/1.76 , height/2]);
	
	var path = d3.geo.path().projection(projection);
	
	var map = svg.selectAll("path")
				 .data(geo_data.features)
				 .enter()
				 .append("path")
				 .attr("d", path)
				 .style("fill", "white")
				 .style("stroke", "black");
	
	var statelabel = svg.append("text")
						.attr("class", "slabel")
						.attr("x", 20)
						.attr("y", 35);
						
	map.on("click", function(d){
		statelabel.text(d.properties.NAME);
		
		map.style("fill", "white");
		d3.select(".dimplechart").remove();
		
			d3.select(this)
			  .style("fill", "orange");	//orange is "rgb(255, 165, 0)"
			
			//read the CFPB data when 'mouseover' event occurs.
			d3.csv("CFPB_USState.csv", function(d){
				d['count'] = +d['count'];
				return d;
			}, drawchart);
		
	})			
};

function getstateData(state, data){
	
	for(i = 0; i < data.length ;i++){
		if(data.key[i] == state){
			return data[i];
		}
	};
};

function drawchart(data){
	var filtered = [];
//		var nested = d3.nest()
//						//grouping the data - states
//					   .key(function(d){
//							return d.State;
//					   })
//					   // grouping the data - products
//					   .key(function(d){
//							return d.Product;
//					   })
//					   // aggregating the data
//					   .rollup(function(leaves){
//							var total = d3.sum(leaves, function(d){
//								return d['count'];
//							})
//							return{
//								'count': total
//							};
//					   })
//					   .entries(data);
				   
	
	for(i = 0; i < data.length; i++){
		if(data[i].State == d3.select("text.slabel").text()){
			filtered.push(data[i])
		}
	};
	//debugger;
	
	//debugger;
	var dimplesvg = dimple.newSvg("body", 590, 350)
						  .attr("class", "dimplechart")
						  .style("top", 300 + "px");
	var myChart = new dimple.chart(dimplesvg, filtered);
	
	
	myChart.setMargins(150,0,10,50);
	var xaxis = myChart.addMeasureAxis("x", "count");
	xaxis.title = "Number of Complaints";
	var yaxis = myChart.addCategoryAxis("y", "Product");
	yaxis.addOrderRule("count");
	var mySeries = myChart.addSeries("Product", dimple.plot.bar);
	mySeries.getTooltipText = function(e){
	//debugger;
		return [
			"Product: " + e.y,
			"Number of Complaints: " + e.xValue
		];
	}
	//myChart.assignClass("dimplechart", "dimchart");
	myChart.defaultColors = [
		new dimple.color("steelblue")
	];
	myChart.draw();	
};
		
		
		