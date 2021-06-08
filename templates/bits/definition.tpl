{$showFootnotes=$showFootnotes|default:true}
{$showStructuredWrapper=$showStructuredWrapper|default:false}
{$showTypos=$showTypos|default:false}

{$def=$row->definition}
{$numDeps=count($row->dependants)}

<div class="
  defWrapper
  {if $def->structured && $showStructuredWrapper}defStructuredWrapper{/if}
  {if $numDeps}hasDependants{/if}
  ">
  <p class="mb-2">
    <span class="def" title="Clic pentru a naviga la acest cuvânt">
      {HtmlConverter::convert($def)}
    </span>
    {foreach $row->tags as $t}
      {include "bits/tag.tpl"}
    {/foreach}
  </p>

  {if $showFootnotes}
    {include "bits/footnotes.tpl" footnotes=$def->getFootnotes()}
  {/if}
  {include "bits/definitionMenu.tpl"}

  {if $showTypos}
    {if count($row->typos)}
      <ul>
        {foreach $row->typos as $typo}
          <li class="typo-wrapper">

            <span class="text-warning">
              {$typo->problem|escape}
            </span>
            <span class="text-muted">
              [{$typo->userName}]
            </span>
            <a href="#"
              class="ignore-typo"
              data-typo-id="{$typo->id}">
              ignoră
            </a>

          </li>
        {/foreach}
      </ul>
    {/if}
  {/if}
</div>

{if $numDeps}
  <div class="collapse dependantsWrapper" id="identical-{$row->definition->id}">
    {foreach $row->dependants as $dep}
      {* keep all parameters unchanged, but suppress the footnotes, since by
         definition they are identical *}
      {include "bits/definition.tpl" row=$dep showFootnotes=false}
    {/foreach}
  </div>
{/if}
