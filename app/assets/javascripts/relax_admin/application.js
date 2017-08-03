//= require jquery
//= require jquery_ujs
//= require tether
//= require bootstrap
//= require selectize
//= require moment
//= require moment/fr
//= require bootstrap-material-datetimepicker
//= require jquery.tagsinput-revisited.min
//= require Chart.min
//= require highcharts
//= require chartkick
//= require bootstrap-datepicker
//= require sweetalert
//= require cocoon
//= require toastr
//= require jquery.nestable
//= require jquery.minicolors
//= require turbolinks
//= require relax_admin/custom
//= require_tree .

$(document).on("turbolinks:load", init);

function init() {
  $(".tags").tagsInput({
    placeholder: "Ajouter un tag",
    delimiter: [",", ";", " "]
  });

  // Scroll to top
  var offset = 250;
  $(window).scroll(function() {
    if ($(this).scrollTop() > offset) {
      $(".scroll-to-top").fadeIn("slow");
    } else {
      $(".scroll-to-top").fadeOut("slow");
    }
  });

  $(".scroll-to-top").click(function(event) {
    $("html, body").animate({ scrollTop: 0 }, 300);
  });

  // Automatic hide alert
  window.setTimeout(function() {
    $(".alert").fadeTo(500, 0).slideUp(500, function() {
      $(this).remove();
    });
  }, 1500);

  // clearForm
  $.fn.clearForm = function() {
    return this.each(function() {
      var type = this.type,
        tag = this.tagName.toLowerCase();
      if (tag === "form") return $(":input", this).clearForm();
      if (type === "text" || type === "password" || tag === "textarea")
        this.value = "";
      else if (type === "checkbox" || type === "radio") this.checked = false;
      else if (tag === "select") this.selectedIndex = -1;
    });
  };

  // CounterUp plugin
  $.fn.counterUp = function(options) {
    var settings = $.extend(
      {
        time: 2000,
        delay: 10
      },
      options
    );

    return this.each(function() {
      var initialCounter = 0;
      var counterObject = $(this);
      var counter = parseInt(counterObject.attr("data-value"), 10);
      var animation = setInterval(frame, settings.delay);

      function frame() {
        if (initialCounter >= counter) {
          counterObject.html(counter);
          clearInterval(animation);
        } else {
          initialCounter += Math.round(
            counter / settings.time * settings.delay
          );
          counterObject.html(initialCounter);
        }
      }
    });
  };

  // MENU
  $(".sub-menu").has(".active").parent().addClass("active");

  // DATA COUNTER
  $("[data-counter='counterup']").counterUp();

  // BULK ACTIONS
  $(".toggle-all").on("change", function() {
    var checked = this.checked;
    $('.table-data-list tbody input[type="checkbox"]').each(function(
      index,
      item
    ) {
      $(item).prop("checked", checked);
    });
  });

  $('.table-data-list input[type="checkbox"]').on("change", function() {
    var length = $('.table-data-list tbody input[type="checkbox"]:checked')
      .length;
    $(".batch-current-selected").html(length);
  });

  // Delete button protection sweetalert
  $(".single-delete").on("click", function(e) {
    e.preventDefault();
    var target = $(this).attr("href");
    var current = window.location.href;

    swal(
      {
        title: "Êtes-vous sûr ?",
        text: "Vous ne serez pas capable de revenir en arrière",
        type: "warning",
        showCancelButton: true,
        confirmButtonClass: "btn-danger",
        cancelButtonClass: "btn-primary",
        confirmButtonText: "Oui, supprimer",
        cancelButtonText: "Annuler",
        closeOnConfirm: false
      },
      function() {
        $.ajax({
          url: target,
          method: "DELETE"
        }).done(function() {
          window.location.href = current;
        });
      }
    );
  });

  // Batch action
  $(".batch-action").on("click", function(e) {
    e.preventDefault();
    var target = $(this).data("action");
    var message = $(this).data("message");
    var current = window.location.href;
    var ids = [];

    $('.table-data-list tbody input[type="checkbox"]:checked').each(function(
      index,
      checkbox
    ) {
      ids.push($(this).val());
    });

    if (ids.length > 0) {
      swal(
        {
          title: "Êtes-vous sûr ?",
          text: message,
          type: "warning",
          showCancelButton: true,
          confirmButtonClass: "btn-danger",
          cancelButtonClass: "btn-primary",
          confirmButtonText: "Oui, supprimer",
          cancelButtonText: "Annuler",
          closeOnConfirm: false
        },
        function() {
          $.ajax({
            url: target,
            method: "post",
            data: {
              ids: ids
            }
          }).done(function() {
            window.location.href = current;
          });
        }
      );
    }
  });

  $(".selectize-single").selectize({});

  $(".selectize-multiple").selectize({
    persist: false,
    plugins: {
      remove_button: {}
    }
  });

  $(".bootstrap-material-date").bootstrapMaterialDatePicker({
    lang: "fr",
    weekStart: 1,
    cancelText: "ANNULER",
    time: false,
    clearButton: true,
    clearText: "EFFACER"
  });

  $(".bootstrap-material-datetime").bootstrapMaterialDatePicker({
    lang: "fr",
    weekStart: 1,
    cancelText: "ANNULER",
    clearButton: true,
    clearText: "EFFACER"
  });

  $(".colorpicker").minicolors();
  //$(':file').filestyle({buttonBefore: true, buttonText: 'Choisissez un fichier', buttonName: 'btn-primary'});

  $("#reset-filters").on("click", function(e) {
    e.preventDefault();

    $("input[name*='filters']").val("");
    $("select[name*='filters'] option:first").prop("selected", true);

    $("#filters").trigger("submit");
  });

  // Handle Both form
  function handleFiltersAndLocation() {
    var url = window.location.href.split("?")[0];

    var filtersParams = $("#filters").serialize();
    var paginationParams = $(".admin-pagination").first().serialize();
    var orderParams = $("#order").serialize();

    parameters = "";
    $.each([filtersParams, paginationParams, orderParams], function(
      index,
      params
    ) {
      if (index !== 0) {
        parameters += "&" + params;
      } else {
        parameters += params;
      }
    });

    window.location.href = url + "?" + parameters;
  }

  // Handle create belongs to
  $("#create-belongs-to-form")
    .on("ajax:success", function(e, data, status, xhr) {
      $("#create-belongs-to-form").text("Done.");
    })
    .on("ajax:error", function(e, xhr, status, error) {
      $("#create-belongs-to-form").text("Failed.");
    });
}
