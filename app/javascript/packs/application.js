/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import fontawesome from '@fortawesome/fontawesome';
import faLock from '@fortawesome/fontawesome-free-solid/faLock';
import faUnlock from '@fortawesome/fontawesome-free-solid/faUnlock';
import faUnlockAlt from '@fortawesome/fontawesome-free-solid/faUnlockAlt';
import faRetweet from '@fortawesome/fontawesome-free-solid/faRetweet';

import '../components/almacenes/ingresos'
import '../components/almacenes/reportes'

fontawesome.library.add(faLock);
fontawesome.library.add(faUnlock);
fontawesome.library.add(faUnlockAlt);
fontawesome.library.add(faRetweet);
