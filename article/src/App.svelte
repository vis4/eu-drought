<script>
    export let name;
    let time = 0;
    let duration;
    let paused = true;
    let playbackRate = 1;
    let video;

    import { csv, json } from 'd3-fetch';
    import AreaChart from './AreaChart.svelte';
    import CountryMap from './CountryMap.svelte';
    import Legend from './Legend.svelte';

    let dataPromise = csv('europe-stats.csv', (d) => {
        return {
            date: new Date(d.date),
            dry1: +d.dry1,
            dry2: +d.dry2,
            dry3: +d.dry3,
            wet1: +d.wet1,
            wet2: +d.wet2,
            wet3: +d.wet3,
        }
    });

    let countriesPromise = json('countries.json');

    $: curFrame = Math.floor(time/duration*frames);

    $: {
        // if (curFrame > 273 && curFrame < 308) {
        //  playbackRate = 0.1;
        // } else {
        //  playbackRate = 1;
        // }
    }

    const frames = 884;

    function setFrame(event) {
        // console.log(event.detail.frame/frames * duration)
        // video.pause();
        video.currentTime = event.detail.frame/frames * duration;
    }

    function videoClick() {
        if (paused) video.play(); else video.pause();
    }

    function videoMetaLoaded() {
        video.currentTime = video.duration+1;
    }
</script>

<style>
    h1 {
        /*text-align: center;*/
        font-weight: 700;
        font-size: 30px;
        margin: 1em auto 1em;
        line-height: 1.1;
    }

    .full-width {
        max-width: 1200px;
        margin: 0 auto;
    }
    p, .width {
        margin: 0 auto 1em;
        max-width: 480px;
    }
    h1.width {
        margin-top: 1em;
    }
    p {
        line-height: 1.5;
        font-family: 'georgia', 'times new roman', serif;
        font-size: 16px;
    }
    .byline {
        font-style: italic;
        font-family: 'georgia', 'times new roman', serif;
        font-size: 16px;
    }
    .controls {
        position: absolute;
        right: 2em;
        top: 2em;
        font-size: 14px;
    }
    @media (max-width: 600px) {
        .controls {
            right: auto;
            left: 0;
            top: -50px;
        }
        .video {
            margin-top: 60px;
        }
    }
    .controls button {
        background: none;
        border: none;
        padding: 0;
        display: inline;
        font-weight: 300;
        color: rgb(0,100,200);
        margin: 0;
        margin-right: 1ex;
        cursor: pointer;
    }
    .controls button:hover {
        text-decoration: underline;
    }
    .controls button.active {
        font-weight: bold;
        color: #222;
    }
</style>

<article>
    <header>
        <h1 class="width">Almost half of Europe's* soil is dryer than normal</h1>

        <div class="byline width">By Gregor Aisch, <time datetime="2019-08-02T18:03:00+01:00" pubdate="pubdate">August 2nd, 2019</time></div>
    </header>

    <p>Once again, Europe is seeing one of the hottest summers since beginning of temperature recording. The record heat also comes with record drought. But how bad is it really?</p>

    <p>To find out I looked for some data, and I found the maps of <b>Soil Moisture Anomalies</b> published by the <a href="http://edo.jrc.ec.europa.eu/edov2/php/index.php?id=1000">European Drought Observatory</a>. The maps show where the top soil (from which most planst extract water) has been dryer or wetter than normal.</p>


    <p>My first step to analyze the data was to download all the available maps (January 1995 until today) as high res images and make a video from them:</p>

    <div class="width">
        <Legend />
    </div>

    <div class="video full-width" style="position: relative;">
        <video on:loadedmetadata={videoMetaLoaded} bind:this={video} style="width: 100%" width="600" src="output.mp4" type="video/mp4"
            preload="auto"
            bind:currentTime={time}
            bind:duration
            bind:paused
            bind:playbackRate
            playsinline
            muted
            on:click={videoClick}
            >
            <source src="output.webm" type="video/webm">
            Your browser does not support the video tag.
        </video>

        {#await countriesPromise}
        {:then countries}
        <CountryMap {countries} />
        {:catch error}
        <p style="color: red">{error.message}</p>
        {/await}
        <div class="controls">
            <button class:active={paused} on:click={videoClick}>pause</button>
            <button class:active={!paused} on:click={videoClick}>play</button>
            <div style="margin-top: 1ex">
                {#each [0.25, 0.5, 1, 1.5, 2] as speed}
                <button on:click={()=>playbackRate=speed} class:active={speed===playbackRate}>{speed}x</button>
                {/each}
            </div>
        </div>
    </div>
    {#await dataPromise}
        <p>...waiting</p>
    {:then data}
        <AreaChart
            bind:curFrame
            on:frame={setFrame}
            {frames}
            {data} />
    {:catch error}
        <p style="color: red">{error.message}</p>
    {/await}

    <p style="margin-top:2em">But looking at the animated maps wasn't enough. Since I didn't find any SMI anomalies raw data on the EDO website, I started to count the pixels in the map images to compute the percentage of the area affected by each condition. To do so I first needed to geo-reference the images and project them using an equal-area projection. The result is shown in the chart above.</p>

    <p>In the chart (and in the map video) we can see that there's always some areas that are dryer and wetter than normal. We also see that 2003 was a pretty dry year (thanks to the <a href="https://en.wikipedia.org/wiki/2003_European_heat_wave">2003 European heat wave</a> that caused more than 70,000 deaths). And on the right side of the chart we see that the drought since 2018 has been as bad or worse than 2003.</p>

    <p>But there's still a lot of noise in the data that makes it hard to see the magnitude of the upwards trend in droughts. To address this issue I loaded the data in R and ran a <i>Loess regression</i> analysis which is designed to reveal trends behind noise. To make seasonal comparison easier (and the chart more space-efficient) I split the data by year. And the result is that since summer 2018 the area dryer than normal has been larger than ever</p>

    <div class="width">
        <iframe class="width" title="Almost half of Europe is dryer than normal" aria-label="Interactive line chart" id="datawrapper-chart-eRRwo" src="//datawrapper.dwcdn.net/eRRwo/1/" scrolling="no" frameborder="0" style="width: 100%;border: none;" height="490"></iframe>
    </div>

    <p>If you want to look at the scripts I wrote to download, process and analyse the map images, feel free to check out <a href="https://github.com/vis4/eu-drought">this Github repository</a>. It also contains the source code for this article and the visualizations. Feel free to re-use or re-mix the images/video as you like.</p>

    <footer class="width" style="border-top: 1px solid #ddd; margin-top: 2em; padding-top: 1em">
        <p style="font-style: italic; font-size: 14px; color:#777">* when I say "Europe" throughout this article, I am actually referring to Europe and the  Mediterranean coastal regions of Africa. I don't know why the EDO is including them in their maps but I decided against removing them from the analysis. After all, climate change also doesn't really care about the borders of Europe.</p>
    </footer>

</article>
