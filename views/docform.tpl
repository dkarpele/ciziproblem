<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-giJF6kkoqNQ00vy+HMDP7azOuL0xtbfIcaT9wjKHr8RbDVddVHyTfAAsrekwKmP1" crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/bootstrap-icons.css">

    <style type="text/css">
      body {
        padding: 20px 0;
      }
    </style>

    <title>Cizi problem</title>
  </head>
  <body class="bg-light">
    <div class="container">
      <main>
        <h2>{{ system_context.get('__name__') }}</h2>

        <div class="row g-3">
          <div class="col-md-7 col-lg-8 border p-3">
            <form id="formTemplate">
              {%- for key, value in context.items() %}
                {%- if value.get('input') == 'radio' %}
                  <fieldset class="row mb-3">
                    <legend class="col-form-label col-sm-2 pt-0">{{ key | replace('_', ' ') | capitalize }}</legend>
                    <div class="col-sm-10">
                      {%- for item in value.get('ids') %}
                        <div class="form-check">
                          <input class="form-check-input" type="radio" name="{{ key }}" id="{{ key }}-{{ item }}" value="{{ item }}" {% if loop.index == 1 %}checked{% endif %}>
                          <label class="form-check-label" for="{{ key }}-{{ item }}">
                            {{ item | replace('_', ' ') | capitalize }}
                          </label>
                        </div>
                      {%- endfor %}
                    </div>
                  </fieldset>
                {% else %}
                  <div class="row mb-3">
                    <label for="input-{{ key }}" class="col-sm-2 col-form-label">{{ key | replace('_', ' ') | capitalize }}</label>
                    <div class="col-sm-10">
                      <input type="{{ value.get('input') }}" class="form-control" id="input-{{ key }}" name="{{ key }}" placeholder="{{ value.get('value') }}" />
                    </div>
                  </div>
                {% endif %}
              {%- endfor %}

              <hr class="my-3">
              <button class="w-100 btn btn-primary btn-lg" type="submit">Generate</button>
            </form>
          </div>

          <div class="col-md-5 col-lg-4">
            <div class="mv-3 p-3 border">
              <h4>
                {{ system_context.get('__authority__') }} <a href="{{ system_context.get('__link__') }}" target="_blank"><i class="bi bi-arrow-up-right-square"></i></a>
              </h4>

              <hr class="my-3">
              <div>
                <h5>ID datové schránky</h5>
                <p class="m-0">{{ system_context.get('__datova_schranka__') }}</p>
              </div>
              {% if system_context.get('__postal_address__') == 'minvnitra_offices_chooser' %}
              <div class="mv-3 p-3">
                <form id="officeSelectorForm">
                  <select id="officeSelector" name="office" class="form-select form-select-sm" aria-label=".form-select-sm minvnitra" style="width:auto">
                    <option>Choose Ministry of Interior office</option>
                    {% for office in minvnitra_offices %}
                      <option id="{{ office.get('name') }}" name="{{ office.get('name') }}" value="{{ office.get('name') }}">{{ office.get('name') }}</option>
                    {% endfor %}
                  </select>
                </form>
              </div>
              <div id="chosenOfficeAddressDiv" style="display: none">
                <h5>Address</h5>
                <address id="chosenOfficeAddress"></address>
              </div>
              {% else %}
              <div>
                <h5>Address</h5>
                <address>
                  {%- for line in system_context.get('__postal_address__', '').split(', ') %}
                   {{- line -}}<br />
                  {%- endfor %}
                </address>
              </div>
              {% endif %}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  </body>

  <script>
    const saveData = (function () {
      var a = document.createElement('a');
      document.body.appendChild(a);
      a.style = 'display: none';
      return function (blob, fileName) {
        const url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = fileName;
        a.click();
        window.URL.revokeObjectURL(url);
      };
    }());

    const officeSelector = document.getElementById('officeSelector');
    const formTemplate = document.getElementById('formTemplate');
    formTemplate.onsubmit = function(e) {
      e.preventDefault();

      const formData = new FormData(this);
      formData.append('__form__', "{{ system_context.get('__name__') }}" );
      if (officeSelector) {
        formData.append('__chosen_office', officeSelector.value);
      };

      fetch('/generate', { method: 'POST', body: formData })
      .then((resp) => (
        resp.blob()
      ))
      .then((blob) => {
        saveData(blob, '{{ name }}.docx');
      });
    };

    const chosenOffice = document.getElementById('chosenOfficeAddress');
    const chosenOfficeAddressDiv = document.getElementById('chosenOfficeAddressDiv');
    officeSelector.onchange = function(e) {
      e.preventDefault();
      const formData = new FormData(officeSelectorForm);
      fetch('/get_office_address', { method: 'POST', body: formData })
      .then(resp => (
        resp.json()
      ))
      .then((data) => {
        if (Object.keys(data).length == 0) {
            chosenOfficeAddressDiv.style.display = "none";
        } else {
          var address = data['territory'] + '<br>' + data['address'] + '<br>' + data['telephone'];
          chosenOffice.innerHTML = address;
          chosenOfficeAddressDiv.style.display = "block";
        }
      });
    };
  </script>
</html>
