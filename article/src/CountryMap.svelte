<script>
	let width = 500;
	let height = 400;

	import * as topojson from 'topojson-client';
	import { geoPath, geoAzimuthalEqualArea } from 'd3-geo';
	import bounds from './bounds.json';

	export let countries = [];
	$: borders = topojson.mesh(countries, countries.objects.ne_10m_admin_0_countries_lakes);
	$: land = topojson.feature(countries, countries.objects.ne_10m_admin_0_countries_lakes);

	$: projection = geoAzimuthalEqualArea()
		.rotate([-10, -52, 0])
		.center([0, 0])
		.fitSize([width, height], bounds);

	$: path = geoPath()
		.projection(projection);
//+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs
	$: borderPath = path(borders);
	$: fillPath = path(land);
</script>

<div bind:clientWidth={width} bind:clientHeight={height}>
	<svg>
		<defs>
			<linearGradient id="top" x1="0" x2="0" y1="0" y2="1">
				<stop stop-color="white" offset="0%" />
				<stop stop-color="rgba(255,255,255,0)" offset="100%" />
			</linearGradient>
			<linearGradient id="bottom" x1="0" x2="0" y1="1" y2="0">
				<stop stop-color="white" offset="10%" />
				<stop stop-color="rgba(255,255,255,0)" offset="100%" />
			</linearGradient>
			<linearGradient id="right" x1="1" x2="0" y1="0" y2="0">
				<stop stop-color="white" offset="10%" />
				<stop stop-color="rgba(255,255,255,0)" offset="100%" />
			</linearGradient>
			<filter id="glow">
	            <feColorMatrix type="matrix" values=
	                        "0 0 0 0   0
	                         0 0 0 0   0
	                         0 0 0 0   0
	                         0 0 0 0.3 0"/>
	            <feMorphology radius="1" operator="erode"></feMorphology>
	            <feGaussianBlur stdDeviation="5" result="blur"/>
				<feComposite operator="out" in="blur" in2="SourceGraphic" result="comp"></feComposite>
	        </filter>

		</defs>
		<path class="fill" d={fillPath} filter="url(#glow)" />
		<path class="borders" d={borderPath}  />
		<rect {width} height="50" style="fill:url(#top)" />
		<rect {width} y={height-100} height="100" style="fill:url(#bottom)" />
		<rect {height} x={width*0.8} width={width*0.2} style="fill:url(#right)" />
	</svg>
</div>

<style>
	div {
		position: absolute;
		top: -3px;
		left: 0;
		width: 100%;
		height: 100%;
		pointer-events: none;
	}
	svg {
		width: 100%;
		height: 100%;
		overflow: hidden;
	}
	.borders {
		fill: none;
		opacity: 0.2;
		stroke: #000;
	}
	.fill {
		fill: rgba(255,255,255,1);
	}
</style>
