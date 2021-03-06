ActiveAdmin.register DelegationField do
  permit_params :name, :slug, :class_name, :id, :options, :description, :_destroy
  belongs_to :delegation_page

  sortable
  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  index as: :sortable do |field|
    label :name

    actions
  end

  form do |f|
    f.inputs :details do

      f.input :name, required: true
      f.input :slug, required: true
      f.input :description, as: :html_editor
      f.input :class_name, as: :select, collection: Mun::DelegationFieldType.type_options,
               required: true,
               label: 'Type of Input'
      f.input :options, input_html: { class: 'select-options tags', :'data-role' => 'tagsinput' }
    end
    f.actions
  end
  
end
