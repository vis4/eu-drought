<script>
    import { scaleLinear, scaleTime } from 'd3-scale';
    import { area } from 'd3-shape';
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    export let frames = 885;
    export let curFrame = 0;
    export let data = [];
    $: filteredData = data.slice(0, mouseOver ? toFrame(mouseDate) : curFrame);

    const padding = { top: 20, right: 25, bottom: 20, left: 25 };

    let width = 300;
    let height = 180;

    $: xScale = scaleTime()
        .domain([toDate(0), toDate(frames)])
        .range([padding.left, width - padding.right]);

    $: yScale = scaleLinear()
        .domain([-0.4, 0.5])
        .range([height - padding.bottom, padding.top]);

    $: xTicks = xScale.ticks(width / 50);
    $: yTicks = [-0.4, -0.2, 0,  0.2,  0.4];

    const areaDefs = [{
        id: 'dry3',
        y0: d => yScale(0),
        y1: d => yScale(d.dry3)
    },{
        id: 'dry2',
        y0: d => yScale(d.dry3),
        y1: d => yScale(d.dry3+d.dry2)
    },{
        id: 'dry1',
        y0: d => yScale(d.dry3+d.dry2),
        y1: d => yScale(d.dry3+d.dry2+d.dry1)
    },{
        id: 'wet3',
        y0: d => yScale(0),
        y1: d => yScale(-d.wet3)
    },{
        id: 'wet2',
        y0: d => yScale(-d.wet3),
        y1: d => yScale(-d.wet3-d.wet2)
    },{
        id: 'wet1',
        y0: d => yScale(-d.wet3-d.wet2),
        y1: d => yScale(-d.wet3-d.wet2-d.wet1)
    }];

    $: areas1 = areaDefs.map(({id, y0, y1}) => {
        return { id, d: area().x(d => xScale(d.date)).y0(y0).y1(y1)(filteredData) };
    });
    $: areas2 = areaDefs.map(({id, y0, y1}) => {
        return { id, d: area().x(d => xScale(d.date)).y0(y0).y1(y1)(data) };
    });


    function toDate(frame) {
        const year = Math.floor(frame / 36) + 1995;
        const month = Math.floor(frame / 3) % 12;
        const day = 1 + 10 * (frame % 3);
        return new Date(year, month, day);
    }

    function toFrame(date) {
        if (!date) return 0;
        const year = date.getFullYear();
        const month = date.getMonth();
        const day = date.getDate();
        return Math.max(0, Math.min(frames, (year-1995) * 36 + month * 3 + Math.floor(day/10)));
    }

    function format(tick) {
        const year = tick.getFullYear();
        return year % 10 === 0 ? year : '\''+String(year).substr(2)
    }

    let chartDiv;
    function setFrame(event) {
        let x= event.clientX - chartDiv.getBoundingClientRect().left;
        let d = xScale.invert(x);
        dispatch('frame', {date:d, frame:toFrame(d)});
    }

    function onMouseMove(event) {
        let x= event.clientX - chartDiv.getBoundingClientRect().left;
        mouseDate = xScale.invert(x);
    }
    let mouseOver = false;
    let mouseDate = null;
</script>

<svelte:window bind:innerWidth={width} />

<div on:mouseenter={() => mouseOver = true} on:mouseleave={() => mouseOver=false} on:mousemove={onMouseMove} class="chart" bind:this={chartDiv} on:click={setFrame}>
    <svg width={width-20} {height}>
        <!-- x axis -->
        <g class="axis x-axis">
            {#each xTicks as tick}
                <g class="tick tick-{ tick }" transform="translate({xScale(tick)},{height})">
                    <line y1="-{height}" y2="-{padding.bottom}" x1="0" x2="0"></line>
                    <text y="-2">{format(tick)}</text>
                </g>
            {/each}
        </g>

        <rect {width} height="70" style="fill:url(#top)" />
        <!-- y axis -->
        <g class="axis y-axis" transform="translate(0, {padding.top})">
            {#each yTicks as tick}
                <g class="tick tick-{tick}" transform="translate(0, {yScale(tick) - padding.bottom})">
                    <line x2="100%"></line>
                    <text y="-4">
                        <tspan>{100*(tick<0?-tick:tick)}</tspan>
                        {#if tick === 0.4}
                        <tspan dx="3">% of area</tspan>
                        <tspan dx="3" class="dryer">dryer than normal</tspan>
                        {:else if tick === -0.4}
                        <tspan dx="3">% of area</tspan>
                        <tspan dx="3" class="wetter">wetter than normal</tspan>
                        {/if}
                    </text>
                </g>
            {/each}
        </g>
        <g class="full">
            {#each areas2 as a}
            <path class="path-area {a.id}" d={a.d}></path>
            {/each}
        </g>

        <g>
            {#each areas1 as a}
            <path class="path-area {a.id}" d={a.d}></path>
            {/each}
        </g>

        <g class="axis y-axis">
            <g class="tick tick-0" transform="translate(0, {yScale(0)})">
                <line x2="100%"></line>
            </g>
        </g>

        <line class="cursor" transform="translate({xScale(mouseOver ? mouseDate : toDate(curFrame))},0)"y1={yScale(0.4)}
        y2={height-padding.bottom} />
    </svg>
</div>

<style>
    svg {
    }
    .tick {
        font-size: .725em;
    }

    .tick line {
        stroke: #ddd;
        shape-rendering: crispEdges;
    }

    .tick text {
        fill: #666;
        text-anchor: start;
    }

    .tick.tick-0 line {
        stroke: #222;
    }

    g.full {
        opacity: 0.3;
    }

    .x-axis .tick text {
        text-anchor: middle;
    }

    .dry3 { fill: #b35806; }
    .dry2 { fill: #f1a340; }
    .dry1 { fill: #fee0b6; }
    .wet3 { fill: #2166ac; }
    .wet2 { fill: #67a9cf; }
    .wet1 { fill: #d1e5f0; }

    .dryer { fill: #b35806; font-weight: bold; }
    .wetter { fill: #2166ac; font-weight: bold; }

    .cursor {
        stroke: gray;
        stroke-width: 2;
        opacity: 0.5;
    }

</style>
