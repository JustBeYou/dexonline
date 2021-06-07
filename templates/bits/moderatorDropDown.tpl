{assign var="name" value=$name|default:'moderators'}
{assign var="mod_selected" value=$mod_selected|default:null}
<select class="form-select" name="{$name}" id="moderatorDropDown">
  <option value="">Orice moderator</option>
  {foreach $moderators as $moderator}
    <option value="{$moderator->id}"
      {if $mod_selected == $moderator->id}selected{/if}
      >{$moderator->nick|escape}</option>
  {/foreach}
</select>
