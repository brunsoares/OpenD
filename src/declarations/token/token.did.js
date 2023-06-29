export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'checkBalance' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'checkSymbol' : IDL.Func([], [IDL.Text], ['query']),
    'payOut' : IDL.Func([], [IDL.Text], []),
    'transfer' : IDL.Func([IDL.Principal, IDL.Nat], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
