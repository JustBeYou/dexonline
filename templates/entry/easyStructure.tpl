{extends "layout-admin.tpl"}

{block "title"}Intrări ușor de structurat{/block}

{block "content"}
  <h3> {$entries|count} de intrări ușor de structurat</h3>

  {foreach $entries as $i => $e}
    <div class="card mb-3">

      <div class="card-header">
        {include "bits/entry.tpl" entry=$e editLink=true}
      </div>

      <div class="card-body pb-0">
        {foreach $searchResults[$i] as $row}
          <p>
            {HtmlConverter::convert($row->definition)}
            <small class="text-muted">{$row->source->shortName}</small>
          </p>
        {/foreach}
      </div>

    </div>
  {/foreach}

{/block}
