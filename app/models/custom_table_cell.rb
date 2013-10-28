# -*- coding: utf-8 -*-
#
# ビルド順番を克服するためのバッドノウハウ
#
module ProMotion
  module Styling
    include ::ProMotion::Conversions

    def set_attributes(element, args = {})
      args.each { |k, v| set_attribute(element, k, v) }
      element
    end

    def set_attribute(element, k, v)
      return element unless element

      if v.is_a?(Hash) && element.respond_to?(k)
        sub_element = element.send(k)
        set_attributes(sub_element, v) if sub_element
      elsif element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      elsif v.is_a?(Array) && element.respond_to?("#{k}") && element.method("#{k}").arity == v.length
        element.send("#{k}", *v)
      else
        # Doesn't respond. Check if snake case.
        if k.to_s.include?("_")
          set_attribute(element, objective_c_method_name(k), v)
        end
      end
      element
    end

    def set_easy_attributes(parent, element, args={})
      attributes = {}

      if args[:resize]
        attributes[:autoresizingMask]  = UIViewAutoresizingNone
        args[:resize].each { |r| attributes[:autoresizingMask] |= map_resize_symbol(r) }
      end

      if [:left, :top, :width, :height].select{ |a| args[a] && args[a] != :auto }.length == 4
        attributes[:frame] = CGRectMake(args[:left], args[:top], args[:width], args[:height])
      end

      set_attributes element, attributes
      element
    end

    def content_height(view)
      height = 0
      view.subviews.each do |sub_view|
        next if sub_view.isHidden
        y = sub_view.frame.origin.y
        h = sub_view.frame.size.height
        if (y + h) > height
          height = y + h
        end
      end
      height
    end

    def closest_parent(type, this_view = nil)
      # iterate up the view hierarchy to find the parent element of "type" containing this view
      this_view ||= view_or_self.superview
      while this_view != nil do
        return this_view if this_view.is_a? type
        this_view = this_view.superview
      end
      nil
    end

    def add(element, attrs = {})
      add_to view_or_self, element, attrs
    end
    alias :add_element :add
    alias :add_view :add

    def remove(element)
      element.removeFromSuperview
      element = nil
    end
    alias :remove_element :remove
    alias :remove_view :remove

    def add_to(parent_element, element, attrs = {})
      parent_element.addSubview element
      if attrs && attrs.length > 0
        set_attributes(element, attrs)
        set_easy_attributes(parent_element, element, attrs)
      end
      element
    end

    def view_or_self
      self.respond_to?(:view) ? self.view : self
    end

    # These three color methods are stolen from BubbleWrap.
    def rgb_color(r,g,b)
      rgba_color(r,g,b,1)
    end

    def rgba_color(r,g,b,a)
      r,g,b = [r,g,b].map { |i| i / 255.0}
      UIColor.colorWithRed(r, green: g, blue:b, alpha:a)
    end

    def hex_color(str)
      hex_color = str.gsub("#", "")
      case hex_color.size
      when 3
        colors = hex_color.scan(%r{[0-9A-Fa-f]}).map{ |el| (el * 2).to_i(16) }
      when 6
        colors = hex_color.scan(%r<[0-9A-Fa-f]{2}>).map{ |el| el.to_i(16) }
      else
        raise ArgumentError
      end

      if colors.size == 3
        rgb_color(colors[0], colors[1], colors[2])
      else
        raise ArgumentError
      end
    end

    protected

    def map_resize_symbol(symbol)
      @_resize_symbols ||= {
        left:     UIViewAutoresizingFlexibleLeftMargin,
        right:    UIViewAutoresizingFlexibleRightMargin,
        top:      UIViewAutoresizingFlexibleTopMargin,
        bottom:   UIViewAutoresizingFlexibleBottomMargin,
        width:    UIViewAutoresizingFlexibleWidth,
        height:   UIViewAutoresizingFlexibleHeight
      }
      @_resize_symbols[symbol] || symbol
    end

  end
end

module ProMotion
  module TableViewCellModule
    include ::ProMotion::Styling

    attr_accessor :data_cell, :table_screen

    def setup(data_cell, screen)
      self.table_screen = WeakRef.new(screen)
      self.data_cell = data_cell

      # TODO: Some of these need to go away. Unnecessary overhead.
      set_cell_attributes
      set_accessory_view
      set_subtitle
      set_image
      set_remote_image
      set_subviews
      set_details
      set_styles
      set_selection_style

      self
    end

    def set_cell_attributes
      data_cell_attributes = data_cell.dup
      [:image, :accessory_action, :editing_style].each { |k| data_cell_attributes.delete(k) }
      set_attributes self, data_cell_attributes
      self
    end

    def set_accessory_view
      if data_cell[:accessory]
        if data_cell[:accessory][:view] == :switch
          switch_view = UISwitch.alloc.initWithFrame(CGRectZero)
          switch_view.setAccessibilityLabel(data_cell[:accessory][:accessibility_label] || data_cell[:title])
          switch_view.addTarget(self.table_screen, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
          switch_view.on = !!data_cell[:accessory][:value]
          self.accessoryView = switch_view
        elsif data_cell[:accessory][:view]
          self.accessoryView = data_cell[:accessory][:view]
          self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        end
      else
        self.accessoryView = nil
      end

      self
    end

    def set_subtitle
      if data_cell[:subtitle] && self.detailTextLabel
        if data_cell[:subtitle].is_a? NSAttributedString
          self.detailTextLabel.attributedText = data_cell[:subtitle]
        else
          self.detailTextLabel.text = data_cell[:subtitle]
        end
        self.detailTextLabel.backgroundColor = UIColor.clearColor
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end
      self
    end

    def set_remote_image
      if data_cell[:remote_image]
        if self.imageView.respond_to?("setImageWithURL:placeholderImage:")
          url = data_cell[:remote_image][:url]
          url = NSURL.URLWithString(url) unless url.is_a?(NSURL)
          placeholder = data_cell[:remote_image][:placeholder]
          placeholder = UIImage.imageNamed(placeholder) if placeholder.is_a?(String)

          self.image_size = data_cell[:remote_image][:size] if data_cell[:remote_image][:size] && self.respond_to?("image_size=")
          self.imageView.setImageWithURL(url, placeholderImage: placeholder)
          self.imageView.layer.masksToBounds = true
          self.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image].has_key?(:radius)
        else
          PM.logger.error "ProMotion Warning: to use remote_image with TableScreen you need to include the CocoaPod 'SDWebImage'."
        end
      end
      self
    end

    def set_image
      if data_cell[:image]

        cell_image = data_cell[:image].is_a?(Hash) ? data_cell[:image][:image] : data_cell[:image]
        cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)

        self.imageView.layer.masksToBounds = true
        self.imageView.image = cell_image
        self.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image].is_a?(Hash) && data_cell[:image][:radius]
      end
      self
    end

    def set_subviews
      tag_number = 0
      Array(data_cell[:subviews]).each do |view|
        # Remove an existing view at that tag number
        tag_number += 1
        existing_view = self.viewWithTag(tag_number)
        existing_view.removeFromSuperview if existing_view

        # Add the subview if it exists
        if view
          view.tag = tag_number
          self.addSubview view
        end
      end
      self
    end

    def set_details
      if data_cell[:details]
        self.addSubview data_cell[:details][:image]
      end
      self
    end

    def set_styles
      if data_cell[:styles] && data_cell[:styles][:label] && data_cell[:styles][:label][:frame]
        ui_label = false
        self.contentView.subviews.each do |view|
          if view.is_a? UILabel
            ui_label = true
            view.text = data_cell[:styles][:label][:text]
          end
        end

        unless ui_label == true
          label ||= UILabel.alloc.initWithFrame(CGRectZero)
          set_attributes label, data_cell[:styles][:label]
          self.contentView.addSubview label
        end

        # TODO: What is this and why is it necessary?
        self.textLabel.textColor = UIColor.clearColor
      else
        cell_title = data_cell[:title]
        cell_title ||= ""
        self.textLabel.backgroundColor = UIColor.clearColor
        if cell_title.is_a? NSAttributedString
          self.textLabel.attributedText = cell_title
        else
          self.textLabel.text = cell_title
        end
      end

      self
    end

    def set_selection_style
      self.selectionStyle = UITableViewCellSelectionStyleNone if data_cell[:no_select]
    end
  end
end

module ProMotion
  class TableViewCell < UITableViewCell
    include ::ProMotion::TableViewCellModule

    attr_accessor :image_size

    # TODO: Is this necessary?
    def layoutSubviews
      super

      if self.image_size && self.imageView.image && self.imageView.image.size && self.imageView.image.size.width > 0
        f = self.imageView.frame
        size_inset_x = (self.imageView.size.width - self.image_size) / 2
        size_inset_y = (self.imageView.size.height - self.image_size) / 2
        self.imageView.frame = CGRectInset(f, size_inset_x, size_inset_y)
      end
    end
  end
end

module Shiori
  class CustomTableCell < ProMotion::TableViewCell
    def layoutSubviews
      super
      self.textLabel.numberOfLines = 0
    end

    def own_height(bounds)
      sum = 0
      sum += height_from_label(self.textLabel, bounds, text_label_options)
      sum += height_from_label(self.detailTextLabel, bounds, detail_text_label_options)
      sum
    end

    def text_label_options
      return NSStringDrawingTruncatesLastVisibleLine
    end

    def detail_text_label_options
      return NSStringDrawingTruncatesLastVisibleLine
    end

    private
    def height_from_label(label, bounds, options)
      return 0 unless label && label.text
      label_bounds = label.text.boundingRectWithSize(
        bounds,
        options: options,
        attributes: NSDictionary.dictionaryWithObject(label.font, forKey:NSFontAttributeName),
        context: nil
      )
      label_bounds.size.height
    end
  end
end
