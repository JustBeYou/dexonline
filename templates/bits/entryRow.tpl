{strip}
<tr id="{$e->id}">
  <td class="col-md-2">
    {include "bits/entry.tpl" entry=$e editLink=true}
  </td>
  <td class="col-md-1 text-center">
    <input type="hidden" name="entryIds[]" value="{$e->id}">
    <input
      type="checkbox"
      name="multipleMains[]"
      value="{$e->id}"
      {if $e->multipleMains}checked{/if}>
  </td>
  <td class="col-md-7 box-padding">
    {foreach $e->getMainLexemes() as $lexeme}
      {include "bits/lexemeLink.tpl" boxed=true}
    {/foreach}
  </td>
  <td class="col-md-1 text-right userNick">{$e->nick}</td>
  <td class="col-md-1 text-right">{$e->modDate|date_format:"%d.%m.%Y"}</td>
</tr>
{/strip}
