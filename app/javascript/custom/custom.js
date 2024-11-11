import * as FilePond from "filepond";

import FilePondPluginImagePreview from 'filepond-plugin-image-preview';

FilePond.registerPlugin(FilePondPluginImagePreview);

const inputElement = document.querySelector("#post-images");

const pond =  FilePond.create(inputElement, {
  credits: {},
  storeAsFile: true,
  allowMultiple: true,
  allowReorder: true
});