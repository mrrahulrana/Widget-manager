class Widget
    include ActiveModel::Model
    #belongs_to :widgetlist
    attr_accessor :id, :name, :description, :kind, :userid, :username, :owner

    validates :name, presence: true
    validates :description, presence: true, length: {in:5..255}
    validates :kind, presence: true
end

class WidgetList
    include ActiveModel::Model
    attr_accessor :widgets

    def widgets_attributes=(attributes)
        @widgets ||= []
        attributes.each do |i, widget_params|
        @widgets.push(Widget.new(widget_params))
        end
    end
    end
