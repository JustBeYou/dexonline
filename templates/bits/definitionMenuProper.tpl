{$showBookmark=$showBookmark|default:false}
{$showCourtesyLink=$showCourtesyLink|default:false}
{$showDate=$showDate|default:false}
{$showDeleteLink=$showDeleteLink|default:false}
{$showDropup=$showDropup|default:true}
{$showEditLink=$showEditLink|default:true}
{$showFlagTypo=$showFlagTypo|default:false}
{$showHistory=$showHistory|default:false}
{$showId=$showId|default:true}
{$showPageLink=$showPageLink|default:true}
{$showPageModal=$showPageModal|default:true}
{$showPermalink=$showPermalink|default:true}
{$showRemoveBookmark=$showRemoveBookmark|default:false}
{$showSource=$showSource|default:true}
{$showStatus=$showStatus|default:false}
{$showUser=$showUser|default:true}
{$showWotd=$showWotd|default:false}

{$def=$row->definition}

<ul class="list-inline dropup">
  {if $showSource}
    <li>
      {t
        count=count($row->sources)
        plural="sources"}
      source{/t}:

      <ul class="list-inline defSourceList">
        {foreach $row->sources as $src}
          <li>
            <a class="ref"
              href="{$wwwRoot}surse"
              title="{$src->name|escape}, {$src->year|escape}"
            >{$src->shortName|escape}
              {if $src->year}
                ({$src->year|regex_replace:"/ .*$/":""})
              {/if}
            </a>
          </li>
        {/foreach}
      </ul>
    </li>
  {/if}

  {if $showCourtesyLink}
    {if $row->sources[0]->courtesyLink}
      <li>
        {t}provided by{/t}
        <a class="ref" href="{$wwwRoot}spre/{$row->sources[0]->courtesyLink}">
          {$row->sources[0]->courtesyText}
        </a>
      </li>
    {/if}
  {/if}

  {if $showStatus}
    <li>
      {t}status{/t}: {$def->getStatusName()}
    </li>
  {/if}

  {if $showUser}
    {if $row->user->id}
      <li>
        {t}added by{/t}
        {strip}
        <a href="{$wwwRoot}utilizator/{$row->user->nick|escape:"url"}">
          {$row->user->nick|escape}
        </a>
        {if $showDate}
          , {LocaleUtil::date($def->createDate)}
        {/if}
        {/strip}
      </li>
    {/if}
  {/if}

  {if $showId}
    {if User::can(User::PRIV_EDIT)}
      <li>
        ID: {$def->id}
      </li>
    {/if}
  {/if}

  {if $showEditLink}
    {if User::can(User::PRIV_EDIT) && !$cfg.global.mirror}
      <li>
        <a href="{$wwwRoot}admin/definitionEdit.php?definitionId={$def->id}">
          editează
        </a>
      </li>
    {/if}
  {/if}

  {if $showWotd}
    <li>
      <i class="glyphicon glyphicon-calendar"></i>
      {if $def->status == Definition::ST_HIDDEN}
        definiție ascunsă
      {else if $row->wotdType == SearchResult::WOTD_NOT_IN_LIST}
        <a href="{$wwwRoot}wotdAdd.php?defId={$def->id}">
          adaugă WotD
        </a>
      {else if $row->wotdType == SearchResult::WOTD_IN_LIST}
        în lista de WotD {if $row->wotdDate}({$row->wotdDate}){/if}
      {else} {* a related definition is in WotD *}
        <span class="text-warning">
          o definiție similară este în WotD
          {if $row->wotdDate}(<a href="/cuvantul-zilei/{$row->wotdDate|replace:'-':'/'}">{$row->wotdDate}</a>){/if}
        </span>
      {/if}
    </li>
  {/if}

  {if $showDeleteLink}
    {if $def->status == Definition::ST_PENDING}
      <li>
        <a href="#"
          class="deleteLink"
          title="Șterge această definiție"
          data-id="{$def->id}">
          șterge
        </a>
      </li>
    {/if}
  {/if}

  {if $showDropup}
    <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        {t}actions{/t}
        <span class="caret"></span>
      </a>

      <ul class="dropdown-menu">
        {if $showFlagTypo}
          {if $skinVariables.typo && !$cfg.global.mirror}
            <li>
              <a href="#"
                data-definition-id="{$def->id}"
                data-toggle="modal"
                data-target="#typoModal">
                <i class="glyphicon glyphicon-flag"></i>
                {t}report a typo{/t}
              </a>
            </li>
          {/if}
        {/if}

        {if $showBookmark}
          {if User::getActive()}
            {if $row->bookmark}
              <li class="disabled">
                <a href="#">
                  <i class="glyphicon glyphicon-heart"></i>
                  {t}added to favorites{/t}
                </a>
              </li>
            {else}
              <li>
                <a class="bookmarkAddButton"
                  href="{$wwwRoot}ajax/bookmarkAdd.php?definitionId={$def->id}">
                  <i class="glyphicon glyphicon-heart"></i>
                  <span
                    data-pending-text="{t}please wait...{/t}"
                    data-added-text="{t}added to favorites{/t}">
                    {t}add to favorites{/t}
                  </span>
                </a>
              </li>
            {/if}
          {/if}
        {/if}

        {if $showRemoveBookmark}
          <li>
            <a class="bookmarkRemoveButton"
              href="{$wwwRoot}ajax/bookmarkRemove.php?definitionId={$def->id}">
              <i class="glyphicon glyphicon-remove"></i>
              <span data-pending-text="{t}please wait...{/t}">
                {t}remove from favorites{/t}
              </span>
            </a>
          </li>
        {/if}

        {if $showPermalink}
          {if $skinVariables.permalink}
            <li>
              <a href="{$wwwRoot}definitie/{$def->lexicon}/{$def->id}"
                title="link direct către această definiție">
                <i class="glyphicon glyphicon-link"></i>
                {t}permalink{/t}
              </a>
            </li>
          {/if}
        {/if}

        {if $showPageLink &&
          $row->sources[0]->hasPageImages &&
          (User::can(User::PRIV_EDIT) ||
            TraineeSource::TraineeCanEditSource(User::getActiveId(), $def->sourceId))}
          <li>
            <a href="#"
              title="arată pagina originală cu această definiție"
              data-toggle="modal"
              data-target="#pageModal"
              data-sourceId="{$def->sourceId}"
              data-word="{$def->lexicon|escape}"
              data-volume="{$def->volume|escape}"
              data-page="{$def->page|escape}">
              <i class="glyphicon glyphicon-file"></i>
              arată originalul
            </a>
          </li>
        {/if}

        {if $showHistory}
          {if User::can(User::PRIV_EDIT) && !$cfg.global.mirror}
            <li>
              <a href="{$wwwRoot}istoria-definitiei?id={$def->id}">
                <i class="glyphicon glyphicon-time"></i>
                istoria definiției
              </a>
            </li>
          {/if}
        {/if}

      </ul>
    </li>
  {/if}

</ul>

{if $showFlagTypo}
  {include "bits/typoForm.tpl"}
{/if}

{*
   Sometimes we need to include the modal separately. For example, nested forms are not
   allowed, so if we are inside a form we cannot include the modal.
*}
{if $showPageLink &&
  $showPageModal &&
  $row->sources[0]->hasPageImages &&
  (User::can(User::PRIV_EDIT) || TraineeSource::TraineeCanEditSource(User::getActiveId(), $def->sourceId))}
  {include "bits/pageModal.tpl"}
{/if}
