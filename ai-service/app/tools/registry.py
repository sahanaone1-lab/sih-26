class ToolRegistry:

    def __init__(self):
        self.tools = {}

    def register(self, name, function):
        self.tools[name] = function

    async def execute(self, name, arguments):

        if name not in self.tools:
            raise ValueError(
                f"Unknown tool: {name}"
            )

        return await self.tools[name](**arguments)