var color = d3.scale.category20();
var width = 1000;
var height = 600;
var svg = d3.select("body")
			.append("svg")
			.attr("width", width)
			.attr("height", height);

d3.json("/CFPB/CFPB_treemapData.json", function(data){
	console.log(data);
	var treemap = d3.layout.treemap()
				.size([width,height])
				.nodes(data);
				
	console.log(treemap)
	
	var cells = svg.selectAll("g")
				   .data(treemap)
				   .enter()
				   .append("g")
				   .attr("class", "cell")
				   
	cells.append("rect")
		 .attr("x", function(d){return d.x;})
		 .attr("y", function(d){return d.y;})
		 .attr("width", function(d){return d.dx})
		 .attr("height", function(d){return d.dy})
		 .attr("fill",function(d){return d.children ? null : color(d.parent.name);})
		 .attr("stroke", "white")
		 //create tooltip
		 .on("mouseover", function(d){
			var xPosition = svg.attr("width")/2 - 125;
			var yPosition = 0;
			var color = d3.select(this).attr("fill");
			
			var tooltip = d3.select("#tooltip")
							.style("left", xPosition + "px")
							.style("top", yPosition + "px");
							
			tooltip.select("#product").text(d.children ? null : d.parent.name).style("color", color);
			tooltip.select("#subproduct").text(d.children ? null : d.name);
			tooltip.select("#value").text(d.children ? null : "Number of Complaints: "+ d.value);						
		 })
});