<a
  href="{Router::link('wotm/view')}/{$smarty.now|date_format:'%Y/%m'}"
  class="widget wotm d-flex flex-md-column flex-xl-row">
  <div class="flex-grow-1">
    <h4>{t}word of the month{/t}</h4><br>
    {if $wotmDef}
      <span class="widget-value">{$wotmDef->lexicon}</span>
    {/if}
  </div>
  <div>
    <img src="{$thumbUrlM}" alt="iconiță cuvântul lunii" class="widget-icon">
  </div>
</a>
