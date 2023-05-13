{%- if theme.footer.beian.enable %}
  <div class="beian">
    {{- next_url('https://beian.miit.gov.cn', theme.footer.beian.icp + ' ') }}
    {%- if theme.footer.beian.gongan_icon_url %}
      <img src="{{ url_for(theme.footer.beian.gongan_icon_url) }}" style="display: inline-block;">
    {%- endif %}
    {%- if theme.footer.beian.gongan_id and theme.footer.beian.gongan_num %}
      {{- next_url('http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=' + theme.footer.beian.gongan_id, theme.footer.beian.gongan_num + ' ') }}
    {%- endif %}
  </div>
{%- endif %}

<div class="copyright">
  {% set copyright_year = date(null, 'YYYY') %}
  &copy; {% if theme.footer.since and theme.footer.since != copyright_year %}{{ theme.footer.since }} – {% endif %}
  <span itemprop="copyrightYear">{{ copyright_year }}</span>
  <span class="with-love">
    <i class="{{ theme.footer.icon.name }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright or author }}</span>

  {%- if config.symbols_count_time.total_symbols %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-chart-area"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.count_total') + __('symbol.colon') }}</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.count_total') }}">{{ symbolsCountTotal(site) }}</span>
  {%- endif %}

  {%- if config.symbols_count_time.total_time %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-coffee"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.time_total') }} &asymp;</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.time_total') }}">{{ symbolsTimeTotal(site, config.symbols_count_time.awl, config.symbols_count_time.wpm, __('symbols_count_time.time_minutes')) }}</span>
  {%- endif %}
</div>

{%- if theme.footer.powered %}
  <div class="powered-by">
    {%- set next_site = 'https://theme-next.org' %}
    {%- if theme.scheme !== 'Gemini' %}
      {%- set next_site = 'https://' + theme.scheme | lower + '.theme-next.org' %}
    {%- endif %}
    {{- __('footer.powered', next_url('https://hexo.io', 'Hexo', {class: 'theme-link'}) + ' & ' + next_url(next_site, 'NexT.' + theme.scheme, {class: 'theme-link'})) }}
  </div>
{%- endif %}

{%- if theme.add_this_id %}
  <div class="addthis_inline_share_toolbox">
    <script src="//s7.addthis.com/js/300/addthis_widget.js#pubid={{ theme.add_this_id }}" async="async"></script>
  </div>
{%- endif %}

{{- next_inject('footer') }}

<!--添加网站运行时间-->
<div class="box">
<span>本站已运行 </span><span id="timeDate">载入天数...</span>
<span> --- </span>
<span>本站已咕咕 </span><span id="guguTime">载入天数...</span>
<script>
    function createtime() {
        const startTime = '11/12/2021 00:00:00',
            start = new Date(startTime)
        let mill = new Date() - start,
            seconds = Math.floor(mill / 1000),
            mins = Math.floor(seconds / 60),
            hours = Math.floor(mins / 60),
            days = Math.floor(hours / 24)
        /*
        const time = {
            seconds: seconds - mins * 60,
            mins: mins - hours * 60,
            hours: hours - days * 24,
        }
        for (const k in time) {
            time[k] = `${time[k]}`.padStart(2, '0')
        }
        */
        document.getElementById("timeDate").innerHTML = `${days} 天`
        //document.getElementById("times").innerHTML = `${time.hours} 小时 ${time.mins} 分 ${time.seconds} 秒`
    }
    //setInterval(createtime, 500)
    createtime()
    
    function calcGuguTime() {
        const lastUpdate = new Date(document.lastModified)
        let mill = new Date() - lastUpdate,
            seconds = Math.floor(mill / 1000),
            mins = Math.floor(seconds / 60),
            hours = Math.floor(mins / 60),
            days = Math.floor(hours / 24)
        document.getElementById("guguTime").innerHTML = `${days} 天`
        //document.write(lastUpdate)
    }
    calcGuguTime()
    //setInterval(calcGuguTime, 500)
    
</script>
</div>

<div class="box">
  <!-- 不蒜子统计 -->
  <span id="busuanzi_container_site_pv">
    本站总访问量 <span id="busuanzi_value_site_pv"></span> 次
  </span>
  <span class="post-meta-divider">|</span>
  <span id="busuanzi_container_site_uv" style='display:none'>
    本站访客数 <span id="busuanzi_value_site_uv"></span> 人
  </span>
  <script async src="//busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
</div>
