<template>
  <transition name="fade" appear>
    <component class="absolute w-100" :is="dynamicComponent" :page="responseData" :key="$route.fullPath"></component>
  </transition>
</template>

<script>
import find from "lodash/find"

// @ is an alias to /src
import { getWagtailPageByPath } from "@/api"
import NotFound from "@/views/NotFound.vue"

export default {
  name: "WagtailPageHandler",
  components: {
    HomePage: () => import('@/views/HomePage.vue'),
    FlexPage: () => import("@/views/FlexPage.vue"),
  },
  data() {
    return {
      dynamicComponent: null,
      responseData: null,
      title: "",
      seoTitle: "",
      description: "",
    }
  },
  metaInfo() {
    return {
      title: this.title,
      titleTemplate(titleChunk) {
        return this.seoTitle ? this.seoTitle : `${titleChunk} - Wagtail + Vue.js`
      },
      meta: [
        { name: 'description', content: this.description }
      ],
    }
  },
  beforeRouteEnter(to, from, next) {
    // called before the route that renders this component is confirmed.
    // does NOT have access to `this` component instance,
    // because it has not been created yet when this guard is called!

    getWagtailPageByPath(to.fullPath)
      .then(response => {
        // catch 302/200 response, render matching Vue component
        // pass page data from response to component

        next(vm => {
          // access to component instance via `vm`
          vm.dynamicComponent = vm.getPageComponent(response.data.meta.type)
          vm.responseData = response.data
          vm.setMetaData(response.data)
        })
      })
      .catch(error => {
        // catch 404 response, page doesn't exist
        // retain request path but render NotFound component instead
        // TODO: find a way to actually return a 404 response

        next(vm => {
          // access to component instance via `vm`
          vm.dynamicComponent = NotFound
          vm.responseData = null
        })
      })
  },
  beforeRouteUpdate(to, from, next) {
    // called when the route that renders this component has changed,
    // but this component is reused in the new route.
    // has access to `this` component instance.

    // TODO: clean up
    // Most of this code is duplicated from the beforeRouteEnter() guard
    // but that guard isn't run when the route changes, only on initial load.

    getWagtailPageByPath(to.fullPath)
      .then(response => {
        this.dynamicComponent = this.getPageComponent(response.data.meta.type)
        this.responseData = response.data
        this.setMetaData(response.data)
        next()
      })
      .catch(error => {
        this.dynamicComponent = NotFound
        this.responseData = null
        next()
      })
  },
  methods: {
    getPageComponent(pageType) {
      // return registered component that's name matches our Wagtail page type
      // strip `pages.` from the Wagtail page type
      return find(
        this.$options.components,
        obj => obj.name === pageType.replace("pages.", "")
      )
    },
    setMetaData(page) {
      this.title = page.title
      this.seoTitle = page.meta.seo_title
      this.description = page.meta.search_description
    },
  },
}
</script>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
</style>
