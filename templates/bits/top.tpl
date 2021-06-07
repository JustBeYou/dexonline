<table id="{$tableId}" class="table tablesorter {if $pager}ts-pager{/if}">
  <thead>
    <tr>
      <th>{t}rank{/t}</th>
      <th>{t}name{/t}</th>
      <th>{t}characters{/t}</th>
      <th>{t}definitions{/t}</th>
      <th>{t}most recent submission{/t}</th>
    </tr>
  </thead>

  {if $pager}
    {include "bits/pager.tpl" id="{$tableId}Pager" colspan="5"}
  {/if}

  <tbody>
    {foreach $data as $place => $row}
      {math equation="max(255 - days, 0)" days=$row->days assign=color}
      <tr class="{cycle values="color1,color2"}">
        <td data-text="{$place}">{$place+1}</td>
        <td class="nick">
          <a href="{Router::link('user/view')}/{$row->userNick|escape:"url"}">
            {$row->userNick|escape}</a>
        </td>
        <td data-text="{$row->numChars}">
          {$row->numChars|nf}
        </td>
        <td data-text="{$row->numDefinitions}">
          {$row->numDefinitions|nf}
        </td>
        <td
          style="color: {$color|string_format:"#%02x0000"}"
          data-text="{$row->timestamp}">
          {LocaleUtil::date($row->timestamp)}
        </td>
      </tr>
    {/foreach}
  </tbody>
</table>
