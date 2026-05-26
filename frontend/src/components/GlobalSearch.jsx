import { useState, useEffect, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { Search, X, ShoppingBag, FileText, Tag, ArrowRight } from "lucide-react";
import api from "../lib/api";

export default function GlobalSearch() {
  const [isOpen, setIsOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [results, setResults] = useState({ products: [], pages: [], categories: [] });
  const [loading, setLoading] = useState(false);
  const inputRef = useRef(null);
  const navigate = useNavigate();
  const debounceRef = useRef(null);

  useEffect(() => {
    const handleKey = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "k") {
        e.preventDefault();
        setIsOpen(true);
      }
      if (e.key === "Escape") close();
    };
    window.addEventListener("keydown", handleKey);
    return () => window.removeEventListener("keydown", handleKey);
  }, []);

  useEffect(() => {
    if (isOpen && inputRef.current) inputRef.current.focus();
  }, [isOpen]);

  const close = () => {
    setIsOpen(false);
    setQuery("");
    setResults({ products: [], pages: [], categories: [] });
  };

  const doSearch = useCallback((q) => {
    if (q.trim().length < 2) {
      setResults({ products: [], pages: [], categories: [] });
      setLoading(false);
      return;
    }
    setLoading(true);
    api.get("/search", { params: { q } })
      .then((res) => setResults(res.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleChange = (e) => {
    const val = e.target.value;
    setQuery(val);
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => doSearch(val), 300);
  };

  const go = (path) => {
    navigate(path);
    close();
  };

  const hasResults = results.products.length > 0 || results.pages.length > 0 || results.categories.length > 0;
  const noResults = query.trim().length >= 2 && !loading && !hasResults;

  if (!isOpen) return (
    <button onClick={() => setIsOpen(true)} className="p-2 rounded-xl hover:bg-white/10 transition-colors text-gray-300 hover:text-cyan-400" title="Search (Ctrl+K)">
      <Search size={18} />
    </button>
  );

  return (
    <div className="fixed inset-0 z-[100] flex items-start justify-center pt-[10vh]" onClick={close}>
      <div className="absolute inset-0 bg-surface-deep/70 backdrop-blur-sm" />

      <div
        className="relative w-full max-w-2xl mx-4 bg-surface-deep/90 backdrop-blur-2xl border border-cyan-500/30 rounded-3xl shadow-[0_0_80px_rgba(0,255,255,0.15)] overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Search Input */}
        <div className="flex items-center gap-3 px-6 py-4 border-b border-white/10">
          <Search size={20} className="text-cyan-400 flex-shrink-0" />
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={handleChange}
            placeholder="Search products, pages, categories..."
            className="flex-1 bg-transparent text-white text-lg placeholder-gray-500 outline-none"
          />
          <kbd className="hidden sm:inline-flex items-center gap-1 text-xs text-gray-500 border border-white/10 rounded-lg px-2 py-1">ESC</kbd>
          <button onClick={close} className="p-1 hover:bg-white/10 rounded-lg transition-colors">
            <X size={18} className="text-gray-400" />
          </button>
        </div>

        {/* Results */}
        <div className="max-h-[60vh] overflow-y-auto">
          {loading && (
            <div className="flex items-center justify-center py-8">
              <div className="animate-spin h-6 w-6 border-2 border-cyan-500 border-t-transparent rounded-full" />
            </div>
          )}

          {!loading && noResults && (
            <div className="text-center py-10 text-gray-500">
              <Search size={32} className="mx-auto mb-3 opacity-50" />
              <p>No results found for "<span className="text-gray-300">{query}</span>"</p>
            </div>
          )}

          {!loading && query.trim().length < 2 && (
            <div className="px-6 py-8 text-center text-gray-500">
              <Search size={32} className="mx-auto mb-3 opacity-30" />
              <p className="text-sm">Type at least 2 characters to search</p>
              <p className="text-xs mt-2 text-gray-600">Search across products, pages, and categories</p>
            </div>
          )}

          {/* Products */}
          {results.products.length > 0 && (
            <div className="px-4 py-3">
              <p className="text-xs font-bold uppercase tracking-widest text-cyan-400 px-2 mb-2">Products</p>
              {results.products.map((p) => (
                <button
                  key={p.id}
                  onClick={() => go(`/shop/${p.slug}`)}
                  className="w-full flex items-center gap-4 px-3 py-3 rounded-xl hover:bg-cyan-500/10 transition-all duration-200 group text-left"
                >
                  <div className="w-12 h-12 rounded-xl bg-white/5 border border-white/10 overflow-hidden flex-shrink-0">
                    {p.image ? (
                      <img src={p.image} alt={p.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center"><ShoppingBag size={16} className="text-gray-600" /></div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-sm truncate group-hover:text-cyan-400 transition-colors">{p.name}</p>
                    <p className="text-xs text-gray-500 truncate">{p.category_name || "General"}{p.description ? ` — ${p.description}` : ""}</p>
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <span className="text-sm font-black text-cyan-400">R{Number(p.price).toFixed(2)}</span>
                    <ArrowRight size={14} className="text-gray-600 group-hover:text-cyan-400 transition-colors" />
                  </div>
                </button>
              ))}
            </div>
          )}

          {/* Categories */}
          {results.categories.length > 0 && (
            <div className="px-4 py-3 border-t border-white/5">
              <p className="text-xs font-bold uppercase tracking-widest text-purple-400 px-2 mb-2">Categories</p>
              {results.categories.map((c) => (
                <button
                  key={c.id}
                  onClick={() => { navigate(`/shop?category=${c.slug}`); close(); }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-purple-500/10 transition-all duration-200 group text-left"
                >
                  <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500/20 to-cyan-500/20 flex items-center justify-center flex-shrink-0">
                    <Tag size={14} className="text-purple-400" />
                  </div>
                  <span className="font-semibold text-sm group-hover:text-purple-400 transition-colors">{c.name}</span>
                  <ArrowRight size={14} className="ml-auto text-gray-600 group-hover:text-purple-400 transition-colors" />
                </button>
              ))}
            </div>
          )}

          {/* Pages */}
          {results.pages.length > 0 && (
            <div className="px-4 py-3 border-t border-white/5">
              <p className="text-xs font-bold uppercase tracking-widest text-gray-400 px-2 mb-2">Pages</p>
              {results.pages.map((p) => (
                <button
                  key={p.path}
                  onClick={() => go(p.path)}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-white/5 transition-all duration-200 group text-left"
                >
                  <div className="w-8 h-8 rounded-lg bg-white/5 border border-white/10 flex items-center justify-center flex-shrink-0">
                    <FileText size={14} className="text-gray-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm group-hover:text-cyan-400 transition-colors">{p.title}</p>
                    <p className="text-xs text-gray-500 truncate">{p.description}</p>
                  </div>
                  <ArrowRight size={14} className="text-gray-600 group-hover:text-cyan-400 transition-colors flex-shrink-0" />
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        {hasResults && (
          <div className="px-6 py-3 border-t border-white/10 flex items-center justify-between">
            <p className="text-xs text-gray-500">
              {results.products.length} products, {results.categories.length} categories, {results.pages.length} pages
            </p>
            <button
              onClick={() => { navigate(`/shop?search=${encodeURIComponent(query)}`); close(); }}
              className="text-xs font-bold text-cyan-400 hover:text-cyan-300 transition-colors flex items-center gap-1"
            >
              View all in Shop <ArrowRight size={12} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
