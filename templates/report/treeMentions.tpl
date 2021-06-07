{extends "layout-admin.tpl"}

{block "title"}Mențiuni despre arbori nestructurați{/block}

{block "content"}

  <h3>{$mentions|count} mențiuni despre arbori nestructurați</h3>

  <table class="table table-sm">
    <thead>
      <tr>
        <th>arbore-sursă</th>
        <th>sens</th>
        <th>arbore-destinație</th>
      </tr>
    </thead>

    <tbody>
      {foreach $mentions as $m}
        <tr>
          <td>
            <a href="{Router::link('tree/edit')}?id={$m->srcId}">{$m->srcDesc}</a>
          </td>
          <td><b>{$m->breadcrumb}</b> {HtmlConverter::convert($m)}</td>
          <td>
            <a href="{Router::link('tree/edit')}?id={$m->destId}">{$m->destDesc}</a>
          </td>
        </tr>
      {/foreach}
    </tbody>
  </table>

{/block}
