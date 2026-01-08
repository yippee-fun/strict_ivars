# frozen_string_literal: true

class StrictIvars::Processor < StrictIvars::BaseProcessor
	#: (Prism::ClassNode) -> void
	def visit_class_node(node)
		new_context { super }
	end

	#: (Prism::ModuleNode) -> void
	def visit_module_node(node)
		new_context { super }
	end

	#: (Prism::BlockNode) -> void
	def visit_block_node(node)
		new_context { super }
	end

	#: (Prism::SingletonClassNode) -> void
	def visit_singleton_class_node(node)
		new_context { super }
	end

	#: (Prism::DefNode) -> void
	def visit_def_node(node)
		new_context { super }
	end

	#: (Prism::IfNode) -> void
	def visit_if_node(node)
		visit(node.predicate)

		branch { visit(node.statements) }
		branch { visit(node.subsequent) }
	end

	#: (Prism::CaseNode) -> void
	def visit_case_node(node)
		visit(node.predicate)

		node.conditions.each do |condition|
			branch { visit(condition) }
		end

		branch { visit(node.else_clause) }
	end

	#: (Prism::DefinedNode) -> void
	def visit_defined_node(node)
		value = node.value

		return if Prism::InstanceVariableReadNode === value

		super
	end

	#: (Prism::EmbeddedVariableNode) -> void
	def visit_embedded_variable_node(node)
		variable = node.variable

		return super unless Prism::InstanceVariableReadNode === variable
		return super if @context.include?(variable.name)

		location = variable.location
		annotations = @annotations
		annotations.push([location.start_character_offset, "{"])
		super
		annotations.push([location.end_character_offset, "}"])
	end

	#: (Prism::InstanceVariableReadNode) -> void
	def visit_instance_variable_read_node(node)
		name = node.name

		unless @context.include?(name)
			location = node.location

			@context << name

			@annotations.push(
				[location.start_character_offset, "(defined?(#{name}) ? "],
				[location.end_character_offset, " : (::Kernel.raise(::StrictIvars::NameError.new(self, :#{name}))))"]
			)
		end

		super
	end

	#: () { () -> void } -> void
	private def new_context
		original_context = @context

		@context = Set[]

		begin
			yield
		ensure
			@context = original_context
		end
	end

	#: () { () -> void } -> void
	private def branch
		original_context = @context
		@context = original_context.dup

		begin
			yield
		ensure
			@context = original_context
		end
	end
end
