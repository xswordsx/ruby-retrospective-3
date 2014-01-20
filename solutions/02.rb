module Constants
  STATUS = {
    "TODO"f => :todo,
    "DONE"f => :done,
    "CURRENT"f => :current
    }.freeze

  PRIORITY = {
    "High"f => :high,
    "Normal"f => :normal,
    "Low"f => :low
    }.freeze

end

class TodoList

  def initialize(item_array)
    @array = item_array.select {|elem| elem.kind_of? TodoItem}
  end

  def each(&block)
    @array.each {|x| yield x}
  end

  def TodoList.parse(todo_rows)
    return_list = []
    todo_rows.split("\n").each {|row| return_list << TodoItem.new(row.to_s)}
    TodoList.new(return_list)
  end

  def filter(criteria)
  end

  def tasks_todo
    @array.count {|x| x.status == :todo}
  end

  def tasks_in_progress
    @array.count {|x| x.status == :current}
  end

  def tasks_done
    @array.count{|x| x.status == :done}
  end

  def completed?
    @array.length == tasks_done
  end

  def filter(criteria)
    @array.select {|x| criteria.call(x)}
  end

end


class TodoItem

  attr_reader :tags
  attr_reader :description

  def initialize(row)
    stripped_list = []
    row.split('|').each {|x| stripped_list << x.strip}

    @status, @description, @priority, @tags = stripped_list
    @tags = stripped_list.pop.split(',') if @tags
  end

  def to_s
    "#{@status} | #{@description} | #{@priority} | #{@tags}"
  end

  def status
    Constants::STATUS[@status]
  end

  def priority
    Constants::PRIORITY[@priority]
  end

end


class Criteria
  
  def initialize(&procedure)
    @procedure = &procedure
  end

  class << self
    def status(status)
      -> (obj) {obj.status == status}
    end

    def priority(priority)
      -> (obj) {obj.priority == priority}
    end

    def tags(tags)
      -> (obj) {obj.tags & tags == tags}
    end
  end
  
end