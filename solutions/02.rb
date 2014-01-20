class TodoList

  attr_reader :task_list
  def initialize(text)
    @task_list = []
    text.lines.each {|line| @task_list << parse(line)}
  end

  def each(&block)
    @task_list.each {|x| yield x}
  end

  def TodoList.parse(line)
    TodoItem.new(line.split('|').map(&:strip))
  end

  def filter(criteria)
  end

  def tasks_todo
    @task_list.count {|x| x.status == :todo}
  end

  def tasks_in_progress
    @task_list.count {|x| x.status == :current}
  end

  def tasks_done
    @task_list.count{|x| x.status == :done}
  end

  def completed?
    @task_list.length == tasks_done
  end

  def filter(criteria)
    @task_list.select {|x| criteria.true_for?(x)}
  end

  def adjoin(other)
    @task_list.dup.concat(other.tasks).uniq
  end

end


class TodoItem

  attr_reader :status, :description, :priority, :tags

  def initialize(*args)
    @status, @description, @priority, @tags = *args
    @tags = *args[-1].split(',')
    @status, @priority = @status.downcase.to_sym, @priority.downcase.to_sym
  end

  def to_s
    "#{@status} | #{@description} | #{@priority} | #{@tags}"
  end
end


class Criteria
  def initialize(&procedure)
    @procedure = procedure
  end

  class << self
    def status(status)
      Criteria.new -> (obj) {obj.status == status}
    end

    def priority(priority)
      Criteria.new -> (obj) {obj.priority == priority}
    end

    def tags(tags)
      Criteria.new -> (obj) {obj.tags & tags == tags}
    end
  end

  def true_for?(obj)
    @procedure.call(obj)
  end

  def &(other)
    Criteria.new -> (obj) {true_for?(obj) and obj.true_for?(other)}
  end

  def !
    Criteria.new -> (obj) {not true_for?(obj)}
  end
end