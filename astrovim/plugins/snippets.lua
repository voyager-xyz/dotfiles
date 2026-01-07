return {
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require("astronvim.plugins.configs.luasnip")(plugin, opts)
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      ls.add_snippets("python", {
        -- Basic dunder methods
        s("__init__", { t("def __init__(self):"), t({"", "    pass"}) }),
        s("__str__", { t("def __str__(self):"), t({"", "    pass"}) }),
        s("__repr__", { t("def __repr__(self):"), t({"", "    pass"}) }),
        s("__del__", { t("def __del__(self):"), t({"", "    pass"}) }),
        
        -- Comparison methods
        s("__eq__", { t("def __eq__(self, other):"), t({"", "    pass"}) }),
        s("__ne__", { t("def __ne__(self, other):"), t({"", "    pass"}) }),
        s("__lt__", { t("def __lt__(self, other):"), t({"", "    pass"}) }),
        s("__le__", { t("def __le__(self, other):"), t({"", "    pass"}) }),
        s("__gt__", { t("def __gt__(self, other):"), t({"", "    pass"}) }),
        s("__ge__", { t("def __ge__(self, other):"), t({"", "    pass"}) }),
        
        -- Arithmetic operators
        s("__add__", { t("def __add__(self, other):"), t({"", "    pass"}) }),
        s("__sub__", { t("def __sub__(self, other):"), t({"", "    pass"}) }),
        s("__mul__", { t("def __mul__(self, other):"), t({"", "    pass"}) }),
        s("__truediv__", { t("def __truediv__(self, other):"), t({"", "    pass"}) }),
        s("__floordiv__", { t("def __floordiv__(self, other):"), t({"", "    pass"}) }),
        s("__mod__", { t("def __mod__(self, other):"), t({"", "    pass"}) }),
        s("__pow__", { t("def __pow__(self, other):"), t({"", "    pass"}) }),
        
        -- Bitwise operators
        s("__and__", { t("def __and__(self, other):"), t({"", "    pass"}) }),
        s("__or__", { t("def __or__(self, other):"), t({"", "    pass"}) }),
        s("__xor__", { t("def __xor__(self, other):"), t({"", "    pass"}) }),
        s("__invert__", { t("def __invert__(self):"), t({"", "    pass"}) }),
        s("__lshift__", { t("def __lshift__(self, other):"), t({"", "    pass"}) }),
        s("__rshift__", { t("def __rshift__(self, other):"), t({"", "    pass"}) }),
        
        -- Unary operators
        s("__neg__", { t("def __neg__(self):"), t({"", "    pass"}) }),
        s("__pos__", { t("def __pos__(self):"), t({"", "    pass"}) }),
        s("__abs__", { t("def __abs__(self):"), t({"", "    pass"}) }),
        
        -- Container methods
        s("__len__", { t("def __len__(self):"), t({"", "    pass"}) }),
        s("__getitem__", { t("def __getitem__(self, key):"), t({"", "    pass"}) }),
        s("__setitem__", { t("def __setitem__(self, key, value):"), t({"", "    pass"}) }),
        s("__delitem__", { t("def __delitem__(self, key):"), t({"", "    pass"}) }),
        s("__contains__", { t("def __contains__(self, item):"), t({"", "    pass"}) }),
        s("__iter__", { t("def __iter__(self):"), t({"", "    pass"}) }),
        s("__next__", { t("def __next__(self):"), t({"", "    pass"}) }),
        s("__reversed__", { t("def __reversed__(self):"), t({"", "    pass"}) }),
        
        -- Type conversion
        s("__int__", { t("def __int__(self):"), t({"", "    pass"}) }),
        s("__float__", { t("def __float__(self):"), t({"", "    pass"}) }),
        s("__complex__", { t("def __complex__(self):"), t({"", "    pass"}) }),
        s("__bool__", { t("def __bool__(self):"), t({"", "    pass"}) }),
        s("__bytes__", { t("def __bytes__(self):"), t({"", "    pass"}) }),
        
        -- Context managers
        s("__enter__", { t("def __enter__(self):"), t({"", "    pass"}) }),
        s("__exit__", { t("def __exit__(self, exc_type, exc_val, exc_tb):"), t({"", "    pass"}) }),
        
        -- Callable
        s("__call__", { t("def __call__(self):"), t({"", "    pass"}) }),
        
        -- Attribute access
        s("__getattr__", { t("def __getattr__(self, name):"), t({"", "    pass"}) }),
        s("__setattr__", { t("def __setattr__(self, name, value):"), t({"", "    pass"}) }),
        s("__delattr__", { t("def __delattr__(self, name):"), t({"", "    pass"}) }),
        s("__getattribute__", { t("def __getattribute__(self, name):"), t({"", "    pass"}) }),
        
        -- Descriptors
        s("__get__", { t("def __get__(self, instance, owner):"), t({"", "    pass"}) }),
        s("__set__", { t("def __set__(self, instance, value):"), t({"", "    pass"}) }),
        s("__delete__", { t("def __delete__(self, instance):"), t({"", "    pass"}) }),
        
        -- Other
        s("__hash__", { t("def __hash__(self):"), t({"", "    pass"}) }),
        s("__format__", { t("def __format__(self, format_spec):"), t({"", "    pass"}) }),
        s("__sizeof__", { t("def __sizeof__(self):"), t({"", "    pass"}) }),
        s("__new__", { t("def __new__(cls):"), t({"", "    pass"}) }),
        
        -- Utility snippets
        s("ifmain", { t('if __name__ == "__main__":'), t({"", "    pass"}) }),
        s("pdb", { t("import pdb; pdb.set_trace()") }),
      })
    end,
  },
}